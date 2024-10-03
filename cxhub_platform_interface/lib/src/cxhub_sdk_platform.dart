import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cxhub_sdk_mixin.dart';

abstract class CxHubSdkPlatform extends PlatformInterface {
  CxHubSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static late CxHubSdkPlatform _instance;

  static CxHubSdkPlatform get instance => _instance;

  static set instance(CxHubSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getMobileInstance() => throw UnimplementedError('getMobileInstance() has not been implemented.');

  Future<String?> getPushToken() => throw UnimplementedError('getPushToken() has not been implemented.');

  Stream<String?> subscribeToPushToken() =>
      throw UnimplementedError('subscribeToPushToken() has not been implemented.');

  Future unsubscribeToPushToken() => throw UnimplementedError('subscribeToPushToken() has not been implemented.');

  Future<MapEntry<String, String>?> getUserId() =>
      throw UnimplementedError('subscribeToPushToken() has not been implemented.');

  Future setUserId(String userIdType, String userIdValue, {bool synchronous = false}) =>
      throw UnimplementedError('subscribeToPushToken() has not been implemented.');

  Future setUserProperties(Map<String, String> properties) =>
      throw UnimplementedError('subscribeToPushToken() has not been implemented.');

  Future collectEvent(String key, {String? value, Map<String, String>? properties, bool deliverImmediately = false}) =>
      throw UnimplementedError('subscribeToPushToken() has not been implemented.');
}
