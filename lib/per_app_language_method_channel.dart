import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'per_app_language_platform_interface.dart';

/// An implementation of [PerAppLanguagePlatform] that uses method channels.
class MethodChannelPerAppLanguage extends PerAppLanguagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('per_app_language');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
