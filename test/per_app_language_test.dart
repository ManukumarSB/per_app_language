import 'package:flutter_test/flutter_test.dart';
import 'package:per_app_language/per_app_language.dart';
import 'package:per_app_language/per_app_language_platform_interface.dart';
import 'package:per_app_language/per_app_language_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPerAppLanguagePlatform
    with MockPlatformInterfaceMixin
    implements PerAppLanguagePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PerAppLanguagePlatform initialPlatform = PerAppLanguagePlatform.instance;

  test('$MethodChannelPerAppLanguage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPerAppLanguage>());
  });

  test('getPlatformVersion', () async {
    PerAppLanguage perAppLanguagePlugin = PerAppLanguage();
    MockPerAppLanguagePlatform fakePlatform = MockPerAppLanguagePlatform();
    PerAppLanguagePlatform.instance = fakePlatform;

    expect(await perAppLanguagePlugin.getPlatformVersion(), '42');
  });
}
