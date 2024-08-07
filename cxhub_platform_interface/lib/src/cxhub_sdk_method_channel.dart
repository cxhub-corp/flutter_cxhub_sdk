import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cxhub_sdk_platform_interface.dart';

/// An implementation of [CxHubSdkPlatform] that uses method channels.
class MethodChannelCxHubSdk extends CxHubSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cxhub_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
