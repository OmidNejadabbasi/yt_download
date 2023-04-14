import 'package:get_it/get_it.dart';
import 'package:youtube_downloader/data/db/database.dart';
import 'package:youtube_downloader/domain/repository/download_item_repository.dart';
import 'package:youtube_downloader/pages/main/link_extractor_dialog/link_extractor_dialog_bloc.dart';
import 'package:youtube_downloader/pages/main/main_screen_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

var sl = GetIt.instance;

Future<void> init() async {
  // bloc
  sl.registerFactory(() => LinkExtractorDialogBloc());
  sl.registerFactory(() => MainScreenBloc(sl()));

  // database and repos
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => DownloadItemRepository(db: sl()));

  sl.registerLazySingleton(() => YoutubeExplode());
}
