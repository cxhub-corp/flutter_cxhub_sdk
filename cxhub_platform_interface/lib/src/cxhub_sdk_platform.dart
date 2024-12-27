import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//import 'package:flutter/cupertino.dart';

abstract class CxHubSdkPlatform extends PlatformInterface {
  CxHubSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static late CxHubSdkPlatform _instance;

  static CxHubSdkPlatform get instance => _instance;

  static set instance(CxHubSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void init({String? param}) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getMobileInstance() =>
      throw UnimplementedError('getMobileInstance() has not been implemented.');

  Future<String?> getPushToken() =>
      throw UnimplementedError('getPushToken() has not been implemented.');

  Stream<String?> subscribeToPushToken() => throw UnimplementedError(
      'subscribeToPushToken() has not been implemented.');

  Future unsubscribeToPushToken() => throw UnimplementedError(
      'unsubscribeToPushToken() has not been implemented.');

  Future<MapEntry<String, String>?> getUserId() =>
      throw UnimplementedError('getUserId() has not been implemented.');

  Future setUserId(String userIdType, String userIdValue,
          {bool synchronous = false}) =>
      throw UnimplementedError('setUserId() has not been implemented.');

  Future setUserProperties(Map<String, String> properties) =>
      throw UnimplementedError('setUserProperties() has not been implemented.');

  Future collectEvent(String key, String? value,
          Map<String, String>? properties, bool deliverImmediately) =>
      throw UnimplementedError('collectEvent() has not been implemented.');

  Future<PermissionResult> checkPermission() =>
      throw UnimplementedError('requestPermission() has not been implemented.');

  Future<PermissionResult> requestPermission() =>
      throw UnimplementedError('requestPermission() has not been implemented.');
}

enum PermissionResult {
  unknown,
  denied,
  granted,
}
