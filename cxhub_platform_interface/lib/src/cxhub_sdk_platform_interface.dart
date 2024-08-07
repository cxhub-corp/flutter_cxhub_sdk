import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cxhub_sdk_method_channel.dart';

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
}
