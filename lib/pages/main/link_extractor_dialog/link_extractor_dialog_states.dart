
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class IdleState{}

class LinksListLoading {}

class LinksLoadedState {
  final List<DownloadItemEntity> links;
  final Video videoMeta;

  LinksLoadedState(this.links, this.videoMeta);
}

class LoadingUnsuccessful {
  final String e;

  LoadingUnsuccessful(this.e);
}
