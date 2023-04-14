import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:fetchme/fetchme.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_downloader/dependency_container.dart';
import 'package:youtube_downloader/domain/entities/app_settings.dart';
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_downloader/domain/repository/download_item_repository.dart';
import 'package:youtube_downloader/pages/main/delete_items_dialog/delete_mode.dart';
import 'package:youtube_downloader/pages/main/main_screen_events.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'main_screen_states.dart';

class MainScreenBloc {
  late DownloadItemRepository _repository;
  List<BehaviorSubject<DownloadItemEntity>> observableItemList = [];

  List<DownloadItemEntity> get itemList =>
      observableItemList.map((e) => e.value).toList();
  BehaviorSubject<int> completedCount = BehaviorSubject.seeded(0);
  BehaviorSubject<int> queueCount = BehaviorSubject.seeded(0);
  PublishSubject<String> errorStream = PublishSubject();
  Connectivity connectivity = Connectivity();

  int _permissionReady = 1;
  late String _localPath;
  BehaviorSubject<AppSettings> appSettings = BehaviorSubject();

  MainScreenBloc(DownloadItemRepository repository) {
    connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        Fetchme.pauseAll();
        print("pause all");
      }
    });

    SharedPreferences.getInstance().then((value) async {
      appSettings.add(AppSettings(
          saveDir: value.getString('saveDir') ?? (await _findLocalPath())!,
          simultaneousDownloads: value.getInt('concurrentDownloads') ?? 3,
          onlyWiFi: value.getBool('onlyWiFi') ?? false,
          onlySendFinishNotification: true));
    });

    _findLocalPath().then((value) {});

    _repository = repository;
    _repository.getAllItems().then((value) {
      observableItemList = value.map((e) => BehaviorSubject.seeded(e)).toList();
      refreshList();
    });
    // _repository.getAllItemsStream().listen((event) {
    //   for(var item in event){
    //
    //   }
    //   observableItemList = event.map((e) => BehaviorSubject.seeded(e)).toList();
    // });

    _mainScreenEvents.stream.listen((event) async {
      if (event.runtimeType == CheckStoragePermission) {
        await _prepare();
      } else if (event.runtimeType == AddDownloadItemEvent) {
        final evt = event as AddDownloadItemEvent;
        //
        String fileName =
            evt.entity.title.replaceAll(RegExp(r'[/|<>*\?":]+'), "-") +
                "-" +
                evt.entity.fps +
                (evt.entity.isAudio ? '.mp3' : '.mp4');
        int counter = 1;
        while (File(appSettings.value.saveDir + "/" + fileName).existsSync()) {
          fileName = evt.entity.title.replaceAll(RegExp(r'[/|<>*\?":]'), "-") +
              "-" +
              evt.entity.fps +
              '($counter).mp4';
          counter++;
        }
        // var taskId = await FlutterDownloader.enqueue(
        //   url: evt.entity.link,
        //   savedDir: _localPath,
        //   fileName: fileName,
        //   saveInPublicStorage: true,
        // );
        // await _repository
        //     .insertDownloadItemEntity(evt.entity.copyWith(taskId: taskId));

        int newTaskId = await Fetchme.enqueue(
            evt.entity.link, appSettings.value.saveDir, fileName);

        var itemEntity = evt.entity.copyWith(taskId: newTaskId);
        var newId = await _repository.insertDownloadItemEntity(itemEntity);
        itemEntity = itemEntity.copyWith(id: newId);
        observableItemList.add(BehaviorSubject.seeded(itemEntity));
        refreshList();
      } else if (event.runtimeType == DeleteDownloadsEvent) {
        final evt = event as DeleteDownloadsEvent;
        if (evt.deleteMode == DeleteMode.delete) {
          evt.idsToBeDeleted.forEach((element) {
            Fetchme.delete(id: element);
          });
          deleteItems(evt);
        } else if (evt.deleteMode == DeleteMode.remove) {
          evt.idsToBeDeleted.forEach((element) {
            Fetchme.remove(id: element);
          });
          deleteItems(evt);
        }
      }
    });

    Fetchme.getUpdateStream().listen((updatedItem) async {
      updatedItem = DownloadItem.fromMap(updatedItem);

      int index = observableItemList
          .map((e) => e.value)
          .toList()
          .indexWhere((element) => element.taskId == updatedItem.id);
      if (updatedItem.status.value > 6) return;
      if (index >= 0) {
        print("item status " +
            updatedItem.downloaded.toString() +
            " code: " +
            updatedItem.status.value.toString());
        updateItemInDbAndList(index, updatedItem);
      } else {
        print("id not found");
      }
      print((await Fetchme.getAllDownloadItems())
          .map((e) => 'taskId=${e.id}, title=${e.fileName.substring(20, 30)}')
          .toList());
    }, onError: (error) {
      error = error as PlatformException;
      DownloadItem errObj = DownloadItem.fromMap(error.details);
      print(error);
      print(error.runtimeType);
      updateItemInDbAndList(getItemIndexWithTaskId(errObj.id), errObj);
      print("Hello  " + errObj.status.toString());
    });

    appSettings.listen((value) {
      Fetchme.setSettings(
        onlyWiFi: value.onlyWiFi,
        concurrentDownloads: value.simultaneousDownloads,
        onlySendFinishNotification: value.onlySendFinishNotification,
      );

      SharedPreferences.getInstance().then((sharedPrefs) async {
        sharedPrefs.setBool('onlyWiFi', value.onlyWiFi);
        sharedPrefs.setInt('concurrentDownload', value.simultaneousDownloads);
        sharedPrefs.setString('saveDir', value.saveDir);
        sharedPrefs.setBool(
            'onlySendFinishNotification', value.onlySendFinishNotification);
      });
    });
  }

  void updateItemInDbAndList(int index, DownloadItem updatedItem) {
    observableItemList[index].add(observableItemList[index].value.copyWith(
        taskId: updatedItem.id,
        downloaded: updatedItem.downloaded,
        link: updatedItem.url,
        status: updatedItem.status.value,
        size: updatedItem.total));
    _repository.updateDownloadItemEntity(observableItemList[index].value);
  }

  void deleteItems(DeleteDownloadsEvent evt) {
    _repository.deleteItems(evt.idsToBeDeleted);
    observableItemList.removeWhere(
        (element) => evt.idsToBeDeleted.contains(element.value.id));
    refreshList();
  }

  void refreshList() {
    _mainScreenStateSubject.add(
      MainScreenState(
        observableItemList: observableItemList,
      ),
    );
  }

  final _mainScreenStateSubject = BehaviorSubject();
  final _mainScreenEvents = StreamController();

  Sink get eventSink => _mainScreenEvents.sink;

  Stream get mainScreenState => _mainScreenStateSubject.stream;

  Future<void> _prepare() async {
    _permissionReady = await _checkPermission();

    if (_permissionReady == 0) {
      await _prepareSaveDir();
      _mainScreenStateSubject.add(MainScreenState(
        observableItemList: observableItemList,
      ));
    } else if (_permissionReady == 1) {
      _mainScreenStateSubject.add(
        PermissionNotGrantedState(message: "Storage Permission not granted"),
      );
    } else {
      _mainScreenStateSubject.add(PermissionDeniedState(
          message: "You have to give permission in settings"));
    }
  }

  Future<int> _checkPermission() async {
    if (Platform.isIOS) return 0;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid && androidInfo.version.sdkInt <= 33) {
      final status = await Permission.manageExternalStorage.status;
      print(status);
      if (status == PermissionStatus.denied) {
        final result = await Permission.storage.request();
        print("Permission result   " + result.toString());
        if (result == PermissionStatus.granted) {
          return 0;
        }
      } else if (status == PermissionStatus.permanentlyDenied) {
        // Permission permanently denied, prompt user to enable from app settings
        return 2;
      } else {
        return 1;
      }
    } else {
      return 0;
    }
    return 2;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      try {
        await savedDir.create(recursive: true);
      } catch (e) {
        print("Error creating directory: " + e.toString());
      }
    }
  }

  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  void dispose() {
    _mainScreenStateSubject.close();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void onItemPauseClicked(int taskId) {
    Fetchme.pause(id: taskId);
  }

  void onItemResumeClicked(int taskId) async {
    int possiblyNewTaskId = await updateLinkIfNeeded(taskId);
    await Fetchme.resume(id: possiblyNewTaskId);
  }

  void onItemRemoveClicked(int taskId) async {
    await Fetchme.delete(id: taskId);
  }

  void onItemOpenClicked(int taskId) async {
    try {
      print('openFile');
      await Fetchme.openFile(id: taskId);
    } on PlatformException catch (e) {
      errorStream.add(e.message ?? 'fuck');
    }
  }

  void onItemRetryClicked(int taskId) async {
    int possiblyNewTaskId = await updateLinkIfNeeded(taskId);
    await Fetchme.resume(id: possiblyNewTaskId);
    await Fetchme.retry(id: taskId);
  }

  Future<int> updateLinkIfNeeded(int taskId) async {
    DownloadItemEntity item =
        itemList.firstWhere((element) => element.taskId == taskId);
    int expTime = getExpirationTimeFromLink(item.link);
    if (expTime != -1) {
      var currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      if (-currentTime + expTime < 1500) {
        print("needs to update");
        var newLink;
        try {
          newLink = await getStreamLink(item.streamTag, item.videoId);
        } catch (err) {
          print("regen timed Out!");
          int index = getItemIndexWithTaskId(taskId);
          if (index > 0) {
            observableItemList[index].add(observableItemList[index]
                .value
                .copyWith(status: DownloadTaskStatus.failed.value));
            print('database updated');
          }
        }
        print("new link found : " + newLink!);
        if (newLink != null) {
          var newDItem = await Fetchme.updateLink(id: taskId, newLink: newLink);
          int index = getItemIndexWithTaskId(taskId);
          if (index > 0) {
            updateItemInDbAndList(index, newDItem);
            print('database updated');
          }
          return newDItem.id;
        }
      }
    }
    return taskId;
  }

  int getItemIndexWithTaskId(int taskId) {
    int index = observableItemList
        .map((e) => e.value)
        .toList()
        .indexWhere((element) => element.taskId == taskId);
    return index;
  }

  getExpirationTimeFromLink(String link) {
    RegExpMatch? match = RegExp(r"expire=(\d+)").firstMatch(link);
    if (match != null) {
      int expTime = int.parse(match.group(1)!);
      return expTime;
    }
    return -1;
  }

  Future<String?> getStreamLink(int tag, String videoId) async {
    YoutubeExplode yt = sl();
    var manifest = await yt.videos.streamsClient
        .getManifest(VideoId(videoId))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException("Can't connect to YouTube");
    });

    var muxedStream =
        firstWhere<MuxedStreamInfo>(manifest.muxed, (p0) => p0.tag == tag);
    if (muxedStream != null) return muxedStream.url.toString();
    var videoStream =
        firstWhere<VideoStreamInfo>(manifest.video, (p0) => p0.tag == tag);
    if (videoStream != null) return videoStream.url.toString();
    var audioStream =
        firstWhere<AudioStreamInfo>(manifest.audio, (p0) => p0.tag == tag);
    if (audioStream != null) return audioStream.url.toString();

    return null;
  }

  T? firstWhere<T>(List<T> list, bool Function(T) predicate) {
    for (T t in list) {
      if (predicate(t)) return t;
    }
    return null;
  }
}
