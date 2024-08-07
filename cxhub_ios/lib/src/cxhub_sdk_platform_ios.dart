import 'package:cxhub_platform_interface/cxhub_platform_interface.dart';


class CxHubSdkPlatformIos extends CxHubSdkPlatform with CxHubChannelMixin {
  CxHubSdkPlatformIos._();

  static void registerWith() {
    CxHubSdkPlatform.instance = CxHubSdkPlatformIos._();
  }
}
