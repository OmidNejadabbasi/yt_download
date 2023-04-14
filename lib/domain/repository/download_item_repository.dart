import 'package:youtube_downloader/data/db/database.dart';
import 'package:youtube_downloader/domain/entities/download_item.dart';
import 'package:youtube_downloader/domain/repository/mapper/download_item_mapper.dart';

class DownloadItemRepository {
  final AppDatabase db;

  const DownloadItemRepository({
    required this.db,
  });

  Future<int> insertDownloadItemEntity(DownloadItemEntity entity) async {
    return await db.insertItems(DownloadItemMapper.mapToDownloadItem(entity));
  }

  Future<void> updateEntity(DownloadItemEntity entity) async {}

  Stream<List<DownloadItemEntity>> getAllItemsStream() {
    return db.getAllDownloadItemsStream().map((event) =>
        event.map((e) => DownloadItemMapper.mapToEntity(e)).toList());
  }

  Future<List<DownloadItemEntity>> getAllItems() async {
    return (await db.getAllItems()).map((e) => DownloadItemMapper.mapToEntity(e)).toList();
  }

  void updateDownloadItemEntity(DownloadItemEntity value) async {
    await db.updateDownloadItem(DownloadItemMapper.mapToDownloadItem(value));
  }

  void deleteItems(List<int> ids) async{
    await db.deleteItems(ids);
  }
}
