import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'per_app_language_method_channel.dart';

abstract class PerAppLanguagePlatform extends PlatformInterface {
  /// Constructs a PerAppLanguagePlatform.
  PerAppLanguagePlatform() : super(token: _token);

  static final Object _token = Object();

  static PerAppLanguagePlatform _instance = MethodChannelPerAppLanguage();

  /// The default instance of [PerAppLanguagePlatform] to use.
  ///
  /// Defaults to [MethodChannelPerAppLanguage].
  static PerAppLanguagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PerAppLanguagePlatform] when
  /// they register themselves.
  static set instance(PerAppLanguagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
