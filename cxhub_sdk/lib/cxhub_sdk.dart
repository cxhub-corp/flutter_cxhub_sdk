import 'package:cxhub_android/cxhub_android.dart';
import 'package:cxhub_ios/cxhub_ios.dart';
import 'package:cxhub_platform_interface/cxhub_platform_interface.dart';
import 'package:flutter/foundation.dart';


class CxHubSdk {
  CxHubSdk._();

  static CxHubSdk? _instance;
  static CxHubSdk get instance => _getOrCreateInstance();

  static CxHubSdk _getOrCreateInstance() {
    if (_instance != null) {
      return _instance!;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      CxHubSdkPlatformAndroid.registerWith();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      CxHubSdkPlatformIos.registerWith();
    }

    _instance = CxHubSdk._();
    return _instance!;
  }

  Future<String?> getPlatformVersion() => CxHubSdkPlatform.instance.getPlatformVersion();
}
