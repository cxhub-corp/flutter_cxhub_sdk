import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cxhub_sdk_platform.dart';

/// An mixin implementation of [CxHubSdkPlatform] that uses method channels.
mixin CxHubSdkMixin {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  late final methodChannel = const MethodChannel('cxhub_sdk')..setMethodCallHandler(_handlePlatformInvokes);

  StreamController<String?>? _pushController;
  Completer<String?>? _pushCompleter;
  Completer<MapEntry<String, String>?>? _userIdCompleter;
  Completer? _setUserPropsCompleter;

  Future<String?> getPlatformVersion() => methodChannel.invokeMethod<String>('getPlatformVersion');

  Future<String?> getMobileInstance() => methodChannel.invokeMethod<String>('getMobileInstance');

  Future<String?> getPushToken() {
    _pushCompleter ??= Completer<String>();
    methodChannel.invokeMethod('getPushToken');
    return _pushCompleter!.future;
  }

  Stream<String?> subscribeToPushToken() {
    if (_pushController == null) {
      _pushController = StreamController<String>();
      _pushController!.onCancel = () {
        methodChannel.invokeMethod('unsubscribeToPushToken');
        _pushController = null;
      };
      methodChannel.invokeMethod('subscribeToPushToken');
    }

    return _pushController!.stream;
  }

  Future<MapEntry<String, String>?> getUserId() {
    _userIdCompleter ??= Completer<MapEntry<String, String>?>();
    methodChannel.invokeMethod('getUserId');
    return _userIdCompleter!.future;
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
      );

  Future setUserProperties(
    Map<String, String> properties,
  ) {
    _setUserPropsCompleter ??= Completer();
    methodChannel.invokeMethod('setUserId', properties);

    return _setUserPropsCompleter!.future;
  }

  Future collectEvent(
    String key,
    String? value,
    Map<String, String>? properties,
    bool deliverImmediately,
  ) =>
      methodChannel.invokeMethod(
        'setUserId',
        {
          'key': key,
          'value': value,
          properties: properties,
          deliverImmediately: deliverImmediately,
        },
      );

  Future _handlePlatformInvokes(MethodCall call) async {
    switch (call.method) {
      case 'emitPushId':
        _pushCompleter?.complete(call.arguments);
        _pushCompleter = null;
        break;

      case 'emitUserId':
        if (call.arguments == null) {
          _userIdCompleter?.complete(null);
          _userIdCompleter = null;
        } else {
          final map = call.arguments as Map<dynamic, dynamic>;
          _userIdCompleter?.complete(MapEntry(map['idType']! as String, map['idValue']! as String));
          _userIdCompleter = null;
        }
        break;

      case 'emitPushIdSub':
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
}
