import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetchme/fetchme.dart';

void main() {
  const MethodChannel channel = MethodChannel('fetchme');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Fetchme.platformVersion, '42');
  });
}
