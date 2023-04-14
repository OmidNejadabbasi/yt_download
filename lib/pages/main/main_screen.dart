import 'dart:async';
import 'dart:ui';

import 'package:badges/badges.dart' as badge;
import 'package:fetchme/fetchme.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youtube_downloader/dependency_container.dart';
import 'package:youtube_downloader/domain/entities/app_settings.dart';
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_downloader/pages/main/delete_items_dialog/delete_items_dialog.dart';
import 'package:youtube_downloader/pages/main/delete_items_dialog/delete_mode.dart';
import 'package:youtube_downloader/pages/main/folder_selector_dialog/folder_selector_dialog.dart';
import 'package:youtube_downloader/pages/main/link_extractor_dialog/link_extractor_dialog.dart';
import 'package:youtube_downloader/pages/main/main_screen_bloc.dart';
import 'package:youtube_downloader/pages/main/main_screen_events.dart';
import 'package:youtube_downloader/shared/widgets/download_item_list_tile.dart';

import '../../shared/styles.dart';
import '../../shared/widgets/ClickableColumn.dart';
import '../../shared/widgets/icon_button.dart';
import 'main_screen_states.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MainScreenBloc _bloc;
  bool isStoragePermissionGranted = false;
  bool _isCompletedTabSelected = true;
  Set<int> selectedIDs = {};
  bool isInSelectMode = false;

  StreamSubscription<String>? errorSubscription;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bloc = sl<MainScreenBloc>();

    _bloc.mainScreenState.listen((event) {
      if (event.runtimeType == PermissionNotGrantedState) {
        setState(() {
          isStoragePermissionGranted = false;
        });
      } else if (event.runtimeType == PermissionDeniedState) {
        // Permission permanently denied, prompt user to enable from app settings
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Permission Denied"),
            content: Text("Please go to app settings and enable storage permission manually."),
            actions: [
              ElevatedButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("App Settings"),
                onPressed: () => openAppSettings(),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          isStoragePermissionGranted = false;
        });
      }
    });

    _bloc.eventSink.add(CheckStoragePermission());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),
      drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            children: [
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16).copyWith(
                    top: MediaQuery.of(context).systemGestureInsets.top),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 35,
                          height: 35,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Youtube Downloader",
                          style: Styles.appTitleStyle,
                        )
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8, top: 8, bottom: 10),
                      child: Row(children: const [
                        Icon(Icons.settings),
                        SizedBox(width: 18),
                        Text("Settings"),
                      ]),
                    ),
                    ClickableColumn(
                      children: [
                        Text(
                          "Folder for files: ",
                          style: Styles.optionLabelText16.copyWith(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                        StreamBuilder(
                          stream: _bloc.appSettings,
                          builder:
                              (context, AsyncSnapshot<AppSettings> snapshot) =>
                                  snapshot.data == null
                                      ? const SizedBox()
                                      : Text(
                                          snapshot.data!.saveDir,
                                          style: Styles.optionLabelText14
                                              .copyWith(color: Colors.teal),
                                        ),
                        ),
                      ],
                      onClick: () async {
                        String? newSavePath = await showDialog(
                            context: context,
                            builder: (ctx) {
                              return const FolderSelectorDialog();
                            });
                        if (!(newSavePath == null)) {
                          _bloc.appSettings.value = _bloc.appSettings.value
                              .copyWith(folderForFiles: newSavePath);
                        }
                      },
                    ),
                    StreamBuilder(
                      stream: _bloc.appSettings,
                      builder: (context, AsyncSnapshot<AppSettings> snapshot) =>
                          snapshot.data == null
                              ? const SizedBox()
                              : ClickableColumn(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Simultaneous downloads",
                                          style: Styles.optionLabelText16
                                              .copyWith(
                                                  color: Colors.black
                                                      .withOpacity(0.7)),
                                        ),
                                        const SizedBox(width: 18),
                                        Text(
                                          snapshot.data!.simultaneousDownloads
                                              .toString(),
                                          style: Styles.optionLabelText16
                                              .copyWith(color: Colors.teal),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                                trackHeight: 1,
                                                overlayShape:
                                                    SliderComponentShape
                                                        .noThumb),
                                            child: Slider(
                                              min: 1,
                                              max: 10,
                                              value: (snapshot.data!
                                                      .simultaneousDownloads)
                                                  .ceil()
                                                  .toDouble(),
                                              onChanged: (val) {
                                                _bloc.appSettings.value = _bloc
                                                    .appSettings.value
                                                    .copyWith(
                                                        simultaneousDownloads:
                                                            val.floor());
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                    ),
                    ClickableColumn(
                      onClick: () {
                        _bloc.appSettings.value = _bloc.appSettings.value
                            .copyWith(
                                onlyWiFi: !_bloc.appSettings.value.onlyWiFi);
                      },
                      children: [
                        StreamBuilder(
                          stream: _bloc.appSettings,
                          builder: (context,
                                  AsyncSnapshot<AppSettings> snapshot) =>
                              snapshot.data == null
                                  ? const SizedBox()
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Download only via Wi-Fi",
                                            style: Styles.optionLabelText16
                                                .copyWith(
                                                    color: Colors.black
                                                        .withOpacity(0.7)),
                                          ),
                                        ),
                                        Switch(
                                            value: _bloc
                                                .appSettings.value.onlyWiFi,
                                            onChanged: (newVal) {
                                              _bloc.appSettings.value = _bloc
                                                  .appSettings.value
                                                  .copyWith(onlyWiFi: newVal);
                                            }),
                                      ],
                                    ),
                        ),
                      ],
                    ),
                    ClickableColumn(
                      onClick: () {
                        _bloc.appSettings.value = _bloc.appSettings.value
                            .copyWith(
                                sendNotificationOnlyWhenFinished: !_bloc
                                    .appSettings
                                    .value
                                    .onlySendFinishNotification);
                      },
                      children: [
                        StreamBuilder(
                          stream: _bloc.appSettings,
                          builder:
                              (context, AsyncSnapshot<AppSettings> snapshot) =>
                                  snapshot.data == null
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Show notification only on completion",
                                                style: Styles.optionLabelText16
                                                    .copyWith(
                                                        color: Colors.black
                                                            .withOpacity(0.7)),
                                              ),
                                            ),
                                            Switch(
                                                value: _bloc.appSettings.value
                                                    .onlySendFinishNotification,
                                                onChanged: (newVal) {
                                                  _bloc.appSettings.value = _bloc
                                                      .appSettings.value
                                                      .copyWith(
                                                          sendNotificationOnlyWhenFinished:
                                                              newVal);
                                                }),
                                          ],
                                        ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              ClickableColumn(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8, top: 8, bottom: 10),
                    child: Row(children: const [
                      Icon(Icons.info),
                      SizedBox(width: 18),
                      Text("About"),
                    ]),
                  ),
                ],
                onClick: () {
                  Navigator.pushNamed(context, '/about');
                },
              )
            ],
          )),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 3),
            ],
          ),
          child: Column(
            children: [
              StreamBuilder(
                builder: (context, snapshot) {
                  errorSubscription = errorSubscription ??
                      _bloc.errorStream.stream.listen((value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(value),
                          duration: const Duration(milliseconds: 1000),
                        ));
                      });
                  return const SizedBox();
                },
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: -2, blurRadius: 5),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: animation.drive(Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      )),
                      child: child,
                    );
                  },
                  child: !isInSelectMode
                      ? Row(
                          key: const ValueKey(1),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            NIconButton(
                              icon: Icons.menu,
                              borderRadius: 100,
                              padding: 12,
                              onPressed: () {
                                _key.currentState!.openDrawer();
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Youtube Downloader',
                                textAlign: TextAlign.center,
                                style: Styles.appTitleStyle,
                              ),
                            ),
                            // NIconButton(
                            //   borderRadius: 100,
                            //   icon: Icons.search,
                            //   onPressed: () {
                            //     Fetchme.getAllDownloadItems().then((value) =>
                            //         print(value
                            //             .map((e) => "${e.id}, ${e.fileName}")
                            //             .toList()));
                            //   },
                            // ),
                          ],
                        )
                      : Row(
                          key: const ValueKey(2),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: NIconButton(
                                  icon: Icons.arrow_back,
                                  onPressed: () {
                                    setState(() {
                                      selectedIDs.clear();
                                      isInSelectMode = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                            NIconButton(
                              icon: Icons.delete,
                              onPressed: () async {
                                DeleteMode deleteItemsConfirmed =
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          int totalSize = 0;
                                          return DeleteItemsDialog(
                                            files: selectedIDs.map((e) {
                                              var itm = _bloc.itemList
                                                  .firstWhere((element) =>
                                                      element.id == e);
                                              totalSize += itm.downloaded;
                                              return [
                                                itm.title,
                                                itm.downloaded
                                              ];
                                            }).toList(),
                                            totalSize: totalSize,
                                          );
                                        });
                                switch (deleteItemsConfirmed) {
                                  case DeleteMode.delete:
                                    _bloc.eventSink.add(DeleteDownloadsEvent(
                                        deleteMode: DeleteMode.delete,
                                        idsToBeDeleted: selectedIDs.toList()));
                                    break;
                                  case DeleteMode.remove:
                                    _bloc.eventSink.add(DeleteDownloadsEvent(
                                        deleteMode: DeleteMode.remove,
                                        idsToBeDeleted: selectedIDs.toList()));
                                    break;
                                  case DeleteMode.abort:
                                    // :)
                                    break;
                                }
                              },
                            ),
                            NIconButton(
                              icon: Icons.select_all,
                              onPressed: () {},
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 0),
              Expanded(
                child: Container(
                  color: Colors.white70,
                  child: StreamBuilder(
                    stream: _bloc.mainScreenState,
                    builder: (context, snapshot) {
                      var state = snapshot.data;

                      if ((snapshot.data is MainScreenState)) {
                        var itemList = (state as MainScreenState)
                            .observableItemList
                            .where((element) => _isCompletedTabSelected
                                ? element.value.status ==
                                    DownloadTaskStatus.complete.value
                                : element.value.status !=
                                    DownloadTaskStatus.complete.value)
                            .toList();
                        _bloc.completedCount.value = _isCompletedTabSelected
                            ? itemList.length
                            : -itemList.length +
                                state.observableItemList.length;

                        _bloc.queueCount.value =
                            state.observableItemList.length -
                                _bloc.completedCount.value;
                        if (itemList.isNotEmpty) {
                          return _buildMainList(context, itemList);
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/idea.png',
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No items to show!\nPress the add button to download new items',
                                style: Styles.labelTextStyle.copyWith(
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 120,
                                width: 100000,
                              ),
                            ],
                          );
                        }
                      } else if (state is PermissionNotGrantedState) {
                        return _buildPermissionNotGrantedView(context, state);
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Image.asset(
                            'assets/images/idea.png',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No items to show!\nPress the add button to download new items',
                            style: Styles.labelTextStyle.copyWith(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 120,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: animation.drive(Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            )),
            child: child,
          );
        },
        duration: const Duration(milliseconds: 250),
        child: isInSelectMode
            ? const SizedBox()
            : BottomNavigationBar(
                onTap: (value) {
                  setState(() {
                    _isCompletedTabSelected = value == 1;
                  });
                },
                currentIndex: _isCompletedTabSelected ? 1 : 0,
                items: [
                  BottomNavigationBarItem(
                    icon: StreamBuilder(
                      stream: _bloc.queueCount,
                      builder: (context, snapshot) => badge.Badge(
                        child: const Icon(Icons.done),
                        badgeContent: Text(snapshot.data.toString(),
                            style: Styles.labelTextStyle),
                        badgeColor: Colors.greenAccent.shade200,
                      ),
                    ),
                    label: "Queue",
                  ),
                  BottomNavigationBarItem(
                    icon: StreamBuilder(
                      stream: _bloc.completedCount,
                      builder: (context, snapshot) => badge.Badge(
                        child: const Icon(Icons.done),
                        badgeContent: Text(snapshot.data.toString(),
                            style: Styles.labelTextStyle),
                        badgeColor: Colors.greenAccent.shade200,
                      ),
                    ),
                    label: "Completed",
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Styles.colorPrimary,
        onPressed: () async {
          var entity = await showDialog(
              context: context,
              builder: (context) {
                return const YoutubeLinkExtractorDialog();
              });
          if (entity.runtimeType != Null) {
            _bloc.eventSink
                .add(AddDownloadItemEvent(entity as DownloadItemEntity));
          }
        },
      ),
    );
  }

  Widget _buildMainList(BuildContext context,
      List<BehaviorSubject<DownloadItemEntity>> itemList) {
    return ListView.builder(
      itemCount: itemList.length + 1,
      itemBuilder: (context, index) {
        if (index == itemList.length) {
          return SizedBox(
            height: 70,
          );
        }
        return StreamBuilder(
            key: ValueKey(itemList[index].value.id!),
            stream: itemList[index],
            builder: (context, AsyncSnapshot<DownloadItemEntity> snapshot) {
              if (snapshot.data == null) {
                return const SizedBox();
              }
              print(snapshot.data.toString());
              var isSelected = selectedIDs.contains(snapshot.data!.id);
              return GestureDetector(
                onTap: () {
                  if (isInSelectMode) {
                    if (isSelected) {
                      selectedIDs.remove(snapshot.data!.id!);
                    } else {
                      selectedIDs.add(snapshot.data!.id!);
                    }
                    setState(() {
                      if (selectedIDs.isEmpty) {
                        isInSelectMode = false;
                      }
                    });
                    return;
                  }
                  if (snapshot.data!.status ==
                      DownloadTaskStatus.complete.value) {
                    _bloc.onItemOpenClicked(snapshot.data!.taskId!);
                  }
                },
                onLongPress: () {
                  if (isInSelectMode) {
                    return;
                  }
                  selectedIDs.add(snapshot.data!.id!);
                  setState(() {
                    isInSelectMode = true;
                  });
                },
                child: DownloadItemListTile(
                  downloadItem: snapshot.data!,
                  onPause: _bloc.onItemPauseClicked,
                  onResume: _bloc.onItemResumeClicked,
                  onRetry: _bloc.onItemRetryClicked,
                  isSelected: isSelected,
                ),
              );
            });
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget _buildPermissionNotGrantedView(BuildContext context,
      PermissionNotGrantedState permissionNotGrantedState) {
    return Container(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Permission not granted'),
          const SizedBox(height: 10),
          ElevatedButton(
            child: const Text('Retry'),
            onPressed: () async {
              _bloc.eventSink.add(CheckStoragePermission());
            },
          ),
        ],
      )),
    );
  }
}
