import 'package:cxhub_sdk/cxhub_sdk.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationToastBuilder extends StatefulWidget {
  const NotificationToastBuilder({super.key});

  @override
  State<NotificationToastBuilder> createState() =>
      _NotificationToastBuilderState();
}

class _NotificationToastBuilderState extends State<NotificationToastBuilder> {
  PostNotificationPermission _state = PostNotificationPermission.granted;

  @override
  void initState() {
    CxHubSdk.checkPermission().then((res) {
      setState(() {
        _state = res;
        _showSnackBar();
      });
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _showSnackBar() {
    if (_state != PostNotificationPermission.granted && context.mounted) {
      final denied = _state == PostNotificationPermission.denied;
      final warning = "Notifications denied${denied ? " forever" : ""}!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(warning),
          duration: const Duration(days: 365),
          action: SnackBarAction(
            label: !denied ? 'REQUEST' : 'SETTINGS',
            onPressed: () {
              if (!denied) {
                CxHubSdk.requestPermission().then((res) {
                  setState(() {
                    _state = res;
                    _showSnackBar();
                  });
                });
              } else {
                openAppSettings();
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 0,
        width: 0,
      );
}
