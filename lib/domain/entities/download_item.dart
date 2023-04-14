

import 'package:fetchme/fetchme.dart';

class DownloadItemEntity {

  final int? id;
  final String link;
  final String title;
  int size;
  int downloaded;
  final String format;
  final String fps;
  final bool isAudio;
  final String quality;
  final int duration;
  final String thumbnailLink;
  final int? taskId;
  final int? status;
  final String videoId;
  final int streamTag;

  DownloadItemEntity({
    this.id,
    required this.link,
    required this.title,
    this.size = -1,
    this.downloaded = 0,
    required this.format,
    required this.fps,
    required this.isAudio,
    required this.quality,
    required this.duration,
    required this.thumbnailLink,
    required this.taskId,
    required this.status,
    required this.videoId,
    required this.streamTag,
  });

  DownloadItemEntity copyWith({
    int? id,
    String? link,
    String? title,
    int? size,
    int? downloaded,
    String? format,
    String? fps,
    bool? isAudio,
    String? quality,
    int? duration,
    String? thumbnailLink,
    int? taskId,
    int? status,
    String? videoId,
    int? streamTag,
  }) {
    return DownloadItemEntity(
      id: id ?? this.id,
      link: link ?? this.link,
      title: title ?? this.title,
      size: size ?? this.size,
      downloaded: downloaded ?? this.downloaded,
      format: format ?? this.format,
      fps: fps ?? this.fps,
      isAudio: isAudio ?? this.isAudio,
      quality: quality ?? this.quality,
      duration: duration ?? this.duration,
      thumbnailLink: thumbnailLink ?? this.thumbnailLink,
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      streamTag: streamTag ?? this.streamTag,
      videoId: videoId ?? this.videoId
    );
  }

  String getProgressPercentage(){
    return '${_format((this.downloaded / this.size)*100)}%';
  }

  bool isCompleted(){
    return status == DownloadTaskStatus.complete.value;
  }

  String _format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  @override
  String toString() {
    return "taskId=$taskId, title=$title, size=$size, downloaded=$downloaded, status=$status";
  }

}