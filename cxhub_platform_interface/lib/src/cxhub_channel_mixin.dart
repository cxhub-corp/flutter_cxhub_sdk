
import 'cxhub_sdk_method_channel.dart';

mixin CxHubChannelMixin {
  final _channel = MethodChannelCxHubSdk();

  Future<String?> getPlatformVersion() => _channel.getPlatformVersion();
}