import 'dart:async';

import 'package:cxhub_sdk/cxhub_sdk.dart';
import 'package:cxhub_sdk_example_local/widgets/login_field.dart';
import 'package:cxhub_sdk_example_local/widgets/property_field.dart';
import 'package:cxhub_sdk_example_local/widgets/simple_field.dart';
import 'package:cxhub_sdk_example_local/widgets/event_field.dart';
import 'package:cxhub_sdk_example_local/widgets/toast_builder.dart';

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: CxHubSdk.getMobileInstance().catchError((e) async {
                debugPrint("getMobileInstance error $e");
                return "ERROR";
              }),
              builder: (context, mobileId) =>
                  SimpleField(
                    name: "MobileId",
                    actionName: "Copy",
                    action: () =>
                        Clipboard.setData(
                            ClipboardData(text: mobileId.data ?? "")),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      mobileId.data ?? "",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
            ),
            StreamBuilder(
              stream: CxHubSdk.subscribeToPushToken().asBroadcastStream().transform(
                  StreamTransformer<String, String>.fromHandlers(
                    handleData: (data, sink) => sink.add(data),
                    handleError: (e, s, sink) {
                      debugPrint("subscribeToPushToken  error $e");
                      sink.add("ERROR");
                    },
                  )),
              builder: (context, pushToken) =>
                  SimpleField(
                    name: "Push token",
                    actionName: "Copy",
                    action: () =>
                        Clipboard.setData(
                            ClipboardData(text: pushToken.data ?? "")),
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
              initial: CxHubSdk.getUserId().catchError((e) {
                debugPrint("getUserId error $e");
                return const MapEntry("ERROR", "ERROR");
              }),
              action: (phone) {
                CxHubSdk.setUserId("Phone", phone).catchError((e) {
                  debugPrint("setUserId error $e");
                });
              },
            ),
            PropertyField(
              name: "UserId (List)",
              actionName: "Send",
              initial: CxHubSdk.getUserId().catchError((e) {
                debugPrint("getUserId error $e");
                return const MapEntry("ERROR", "ERROR");
              }),
              action: (type, value) {
                CxHubSdk.setUserId(type, value).catchError((e) {
                  debugPrint("setUserId error $e");
                });
              },
              types: const {
                "Email": "Email",
                "VKID": "VKID",
                "WebId": "WebId",
              },
            ),
            PropertyField(
              name: "User property",
              actionName: "Send",
              action: (type, value) {
                CxHubSdk.setUserProperties({type: value}).catchError((e) {
                  debugPrint("setUserProperties error $e");
                });
              },
              types: const {
                "Email": "Email",
                "City": "City",
                "FirstName": "FirstName",
                "MiddleName": "MiddleName",
                "LastName": "LastName",
              },
            ),
            EventField(
              name: "Collect event",
              actionName: "Send",
              action: (key, value) {
                CxHubSdk.collectEvent(key, value: value, properties: null)
                    .catchError((e) {
                  debugPrint("collectEvent error $e");
                });
              },
            ),
            MaterialButton(
                child: const Text("Send event"),
                onPressed: () {
                  CxHubSdk.collectEvent("CustomEvent",
                      deliverImmediately: true);
                }),
            const NotificationToastBuilder(),
          ],
        ),
      ),
    );
  }
}
