import 'package:drift/drift.dart';
import 'package:youtube_downloader/data/db/database.dart';
import 'package:youtube_downloader/domain/entities/download_item.dart';

class DownloadItemMapper {
  static DownloadItemEntity mapToEntity(DownloadItem item) {
    return DownloadItemEntity(
        id: item.id,
        link: item.link,
        title: item.title,
        format: item.format ?? '',
        fps: item.fps ?? '',
        isAudio: item.isAudio,
        thumbnailLink: item.thumbnail_link ?? "",
        duration: item.duration ?? 0,
        size: item.size,
        downloaded: item.downloaded,
        quality: item.quality ?? '',
        taskId: item.task_id,
        status: item.status,
        videoId: item.videoId,
        streamTag: item.streamTag);
  }

  static DownloadItemsCompanion mapToDownloadItem(DownloadItemEntity item) {
    return DownloadItemsCompanion(
        id: item.id == null ? const Value.absent() : Value(item.id!),
        link: Value(item.link),
        title: Value(item.title),
        format: Value(item.format),
        fps: Value(item.fps),
        isAudio: Value(item.isAudio),
        thumbnail_link: Value(item.thumbnailLink),
        duration: Value(item.duration),
        size: Value(item.size),
        downloaded: Value(item.downloaded),
        quality: Value(item.quality),
        task_id: Value(item.taskId),
        status: Value(item.status),
        streamTag: Value(item.streamTag),
        videoId: Value(item.videoId));
  }
}
