
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_downloader/pages/main/delete_items_dialog/delete_mode.dart';

class CheckStoragePermission {}

class AddDownloadItemEvent{

  final DownloadItemEntity entity;

  AddDownloadItemEvent(this.entity);
}

class DeleteDownloadsEvent{
  DeleteMode deleteMode;
  List<int> idsToBeDeleted;

  DeleteDownloadsEvent({required this.deleteMode, required this.idsToBeDeleted});
}