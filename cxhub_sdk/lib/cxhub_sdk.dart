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

  /// Init SDK [method] with optional [String? param]
  /// * [param] is [null] by default, and using only for [RuStore] implementation
  /// to define RuStore [projectId]
  ///
  /// Using:
  /// ```dart
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   CxHubSdk.init(); // <<<
  ///   CxHubSdk.collectEvent("AppCreate");
  ///   runApp(const MyApp());
  /// }
  /// ```
  static void init({String? param}) =>
      CxHubSdkPlatform.instance.init(param: param);

  /// Default platform version [method] return [Future<String?>]
  /// [String] contains platform and FCM|HMS|RuStore transport implementation
  /// for Android
  static Future<String?> getPlatformVersion() =>
      CxHubSdkPlatform.instance.getPlatformVersion();

  /// [Method] returns mobile instance id of SDK client
  ///
  /// Mobile instance id define client device while not logged in.
  /// When logged in it define current user's device.
  static Future<String?> getMobileInstance() =>
      CxHubSdkPlatform.instance.getMobileInstance();

  /// [Method] returns push token
  ///
  /// You can get push token of current transport implementation for test purposes.
  /// Token string  can be null when sdk not initialized on the first run
  static Future<String?> getPushToken() =>
      CxHubSdkPlatform.instance.getPushToken();

  /// [Method] subscribes to push token of current transport implementation for test purposes.
  ///
  /// You can subscribe push token of current transport implementation for test purposes and get updates of it when it changes.
  /// Token string can be null when sdk not initialized on the first run
  static Stream<String?> subscribeToPushToken() =>
      CxHubSdkPlatform.instance.subscribeToPushToken();

  /// [Method] returns [MapEntry<String, String>?] where:
  /// * [key] is type of user id (Phone|Email|any unique param from personal profile)
  /// * [value] is user id value itself
  ///
  /// Can be null when not set, use [CxHubSdk.setUserId(String userIdType, String userIdValue)]
  static Future<MapEntry<String, String>?> getUserId() =>
      CxHubSdkPlatform.instance.getUserId();

  /// [Method] set user id [type] and [value]
  /// * [userIdType] - Phone|Email|any unique param from personal profile
  /// * [value] is user id value itself
  static Future setUserId(String userIdType, String userIdValue) =>
      CxHubSdkPlatform.instance.setUserId(userIdType, userIdValue);

  /// [Method] set any user properties
  /// * [Map<String, String> properties] - bundle of any user properties in cxhub project settings
  static Future setUserProperties(Map<String, String> properties) =>
      CxHubSdkPlatform.instance.setUserProperties(properties);

  /// [Method] send custom user event
  /// * [String key] - event type (for example AppCreate)
  /// * [String? value] - additional value for event (optional)
  /// * [Map<String, String>? properties] - additional properties for event (optional)
  /// * [bool deliverImmediately] - when "true" SDK try to send event immediately,
  /// otherwise send with bunch of other events by inner timer
  static Future collectEvent(String key,
          {String? value,
          Map<String, String>? properties,
          bool deliverImmediately = false}) =>
      CxHubSdkPlatform.instance
          .collectEvent(key, value, properties, deliverImmediately);

  static Future<PostNotificationPermission> checkPermission() =>
      CxHubSdkPlatform.instance.checkPermission().then((value) =>
          PostNotificationPermission
              .values[PermissionResult.values.indexOf(value)]);

  static Future<PostNotificationPermission> requestPermission() =>
      CxHubSdkPlatform.instance.requestPermission().then((value) =>
          PostNotificationPermission
              .values[PermissionResult.values.indexOf(value)]);
}

enum PostNotificationPermission {
  notGranted,
  denied,
  granted,
}
