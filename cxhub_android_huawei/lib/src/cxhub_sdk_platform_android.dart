import 'package:cxhub_platform_interface/cxhub_platform_interface.dart';


class CxHubSdkPlatformAndroid extends CxHubSdkPlatform with CxHubChannelMixin {
  CxHubSdkPlatformAndroid._();

  static void registerWith() {
    CxHubSdkPlatform.instance = CxHubSdkPlatformAndroid._();
  }
}
