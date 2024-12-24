import 'dart:async';

//import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

import 'cxhub_sdk_platform.dart';

/// An mixin implementation of [CxHubSdkPlatform] that uses method channels.
mixin CxHubSdkMixin {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  late final methodChannel = const MethodChannel('cxhub_sdk')
    ..setMethodCallHandler(_handlePlatformInvokes);

  StreamController<String?>? _pushController;
  Completer<String?>? _pushCompleter;
  Completer<MapEntry<String, String>?>? _userIdCompleter;
  Completer? _setUserPropsCompleter;

  void init({String? param}) {
    methodChannel.invokeMethod('init', param);
    //if (Platform.isIOS) {
    //  requestPushNotificationPermission().then((value) async {
    //   registerDevice();
    // });
    //}
    if (Platform.isIOS) {
      requestPushNotificationPermission().then((value) async {
        //   registerDevice();
      });
    }
  }

  Future<String?> getPlatformVersion() =>
      methodChannel.invokeMethod<String>('getPlatformVersion');

  Future<String?> getMobileInstance() =>
      methodChannel.invokeMethod<String>('getMobileInstance');

  Future<String?> getPushToken() {
    _pushCompleter ??= Completer<String>();
    final future = _pushCompleter!.future;

    methodChannel.invokeMethod('getPushToken').onError((e, s) {
      _pushCompleter?.completeError(e!, s);
      _pushCompleter = null;
    });

    return future;
  }

  Stream<String?> subscribeToPushToken() {
    if (_pushController == null) {
      _pushController = StreamController<String>();
      _pushController!.onCancel = () {
        methodChannel.invokeMethod('unsubscribeToPushToken').ignore();
        _pushController = null;
      };
      methodChannel.invokeMethod('subscribeToPushToken').onError((e, s) {
        _pushController?.addError(e!, s);
        _pushController = null;
      });
    }
    final stream = _pushController!.stream;
    return stream;
  }

  Future<MapEntry<String, String>?> getUserId() {
    _userIdCompleter ??= Completer<MapEntry<String, String>?>();
    final future = _userIdCompleter!.future;

    methodChannel.invokeMethod('getUserId').onError((e, s) {
      _userIdCompleter?.completeError(e!, s);
      _userIdCompleter = null;
    });

    return future;
  }

  Future setUserId(
    String userIdType,
    String userIdValue, {
    bool synchronous = false,
  }) =>
      methodChannel.invokeMethod(
        'setUserId',
        {
          'idType': userIdType,
          'idValue': userIdValue,
          'synchronous': synchronous,
        },
      )..ignore();

  Future setUserProperties(Map<String, String> properties) {
    _setUserPropsCompleter ??= Completer();
    final future = _setUserPropsCompleter!.future;
    methodChannel.invokeMethod('setUserProperties', properties).onError((e, s) {
      _setUserPropsCompleter?.completeError(e!, s);
      _setUserPropsCompleter = null;
    });

    return future;
  }

  Future collectEvent(
    String key,
    String? value,
    Map<String, String>? properties,
    bool deliverImmediately,
  ) =>
      methodChannel.invokeMethod(
        'collectEvent',
        {
          'key': key,
          'value': value,
          properties: properties,
          deliverImmediately: deliverImmediately,
        },
      )..ignore();

  Future _handlePlatformInvokes(MethodCall call) async {
    switch (call.method) {
      case 'emitPushToken':
        _pushCompleter?.complete(call.arguments);
        _pushCompleter = null;
        break;

      case 'emitUserId':
        if (call.arguments == null) {
          _userIdCompleter?.complete(null);
          _userIdCompleter = null;
        } else {
          final map = call.arguments as Map<dynamic, dynamic>;
          _userIdCompleter?.complete(
              MapEntry(map['idType']! as String, map['idValue']! as String));
          _userIdCompleter = null;
        }
        break;

      case 'emitPushTokenSub':
        _pushController?.add(call.arguments);
        break;

      case 'emitSetPropsResult':
        if (call.arguments == null) {
          _setUserPropsCompleter?.complete();
          _setUserPropsCompleter = null;
        } else {
          final map = call.arguments as Map<dynamic, dynamic>;
          final cause = map['cause'] as String?;
          final end = cause == null ? 'cause $cause' : '';
          _setUserPropsCompleter?.completeError('${map["message"]} $end');
          _setUserPropsCompleter = null;
        }
        break;

      default:
        return Future.error('${call.method}() not implemented!');
    }

    return "success";
  }

  //iOS

  Future<void> requestPushNotificationPermission() async {
    try {
      await methodChannel.invokeMethod("requestNotificationPermissions");
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    }
  }

  Future<void> registerDevice() async {
    try {
      await methodChannel.invokeMethod("registerForPushNotifications");
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    }
  }
}
