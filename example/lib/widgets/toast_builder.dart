import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationToastBuilder extends StatelessWidget {
  const NotificationToastBuilder({super.key});

  @override
  Widget build(BuildContext context) =>
      FutureBuilder(
        future: Permission.notification.isDenied.then((denied) {
          if (denied && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Notifications denied!"),
                duration: const Duration(days: 365),
                action: SnackBarAction(
                  label: 'REQUEST',
                  onPressed: () {
                    if (denied) {
                      Permission.notification.request();
                    }
                  },
                ),
              ),
            );
          }
        }),
        builder: (context, snapshot) =>
        const SizedBox(
          height: 0,
          width: 0,
        ),
      );
}
