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

  static Future<String?> getPlatformVersion() => CxHubSdkPlatform.instance.getPlatformVersion();

  static Future<String?> getMobileInstance() => CxHubSdkPlatform.instance.getMobileInstance();

  static Future<String?> getPushToken() => CxHubSdkPlatform.instance.getPushToken();

  static Stream<String?> subscribeToPushToken() => CxHubSdkPlatform.instance.subscribeToPushToken();

  static Future unsubscribeToPushToken() => CxHubSdkPlatform.instance.unsubscribeToPushToken();

  static Future<MapEntry<String, String>?> getUserId() => CxHubSdkPlatform.instance.getUserId();

  static Future setUserId(String userIdType, String userIdValue) =>
      CxHubSdkPlatform.instance.setUserId(userIdType, userIdValue);

  static Future setUserProperties(Map<String, String> properties) =>
      CxHubSdkPlatform.instance.setUserProperties(properties);

  static Future collectEvent(String key, {String? value, Map<String, String>? properties, bool deliverImmediately = false}) =>
      CxHubSdkPlatform.instance.collectEvent(key, value, properties, deliverImmediately);
}
