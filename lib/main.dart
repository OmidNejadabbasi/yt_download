import 'package:fetchme/fetchme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_downloader/dependency_container.dart';
import 'package:youtube_downloader/pages/about/about.dart';
import 'package:youtube_downloader/pages/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  // await FlutterDownloader.initialize(
  //     debug: true // optional: set false to disable printing logs to console
  // );
  Fetchme.initialize(concurrentDownloads: 10, progressInterval: 1000);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omid Youtube Downloader',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MainScreen(),
      routes: {'/about': (context) => AboutPage()},
    );
  }
}
