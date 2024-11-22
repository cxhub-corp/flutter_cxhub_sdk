import 'package:cxhub_sdk/cxhub_sdk.dart';
import 'package:cxhub_sdk_example/widgets/login_field.dart';
import 'package:cxhub_sdk_example/widgets/property_field.dart';
import 'package:cxhub_sdk_example/widgets/simple_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CxHubSDK Example App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder(
            future: CxHubSdk.getMobileInstance(),
            builder: (context, mobileId) => SimpleField(
              name: "MobileId",
              actionName: "Copy",
              action: () => Clipboard.setData(ClipboardData(text: mobileId.data ?? "")),
              child: Text(
                overflow: TextOverflow.ellipsis,
                mobileId.data ?? "",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          StreamBuilder(
            stream: CxHubSdk.subscribeToPushToken(),
            builder: (context, pushToken) => SimpleField(
              name: "Push token",
              actionName: "Copy",
              action: () => Clipboard.setData(ClipboardData(text: pushToken.data ?? "")),
              child: Text(
                overflow: TextOverflow.ellipsis,
                pushToken.data ?? "",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          LoginField(
            name: "UserId (Phone)",
            actionName: "Send",
            initial: CxHubSdk.getUserId(),
            action: (phone) {
              CxHubSdk.setUserId("Phone", phone);
            },
          ),
          PropertyField(
            name: "User property",
            actionName: "Send",
            action: (type, value) {
              CxHubSdk.setUserProperties({type: value});
            },
            types: const {
              "Email": "Email",
              "City": "City",
              "FirstName": "FirstName",
              "MiddleName": "MiddleName",
              "LastName": "LastName",
            },
          ),
        ],
      ),
    );
  }
}
