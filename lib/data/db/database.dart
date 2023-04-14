import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_downloader/data/models/download_item.dart';

part 'database.g.dart';

@DriftDatabase(tables: [DownloadItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<DownloadItem>> getAllDownloadItemsStream() {
    return select(downloadItems).watch();
  }

  Future<List<DownloadItem>> getAllItems() {
    return select(downloadItems).get();
  }

  Future<int> insertItems(DownloadItemsCompanion item) {
    return into(downloadItems).insert(item);
  }

  Future<void> updateDownloadItem(DownloadItemsCompanion item) {
    return update(downloadItems).replace(item);
  }
  
  Future<void> deleteItems(List<int> ids){
    return (delete(downloadItems)..where((tbl) => tbl.id.isIn(ids))).go();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
