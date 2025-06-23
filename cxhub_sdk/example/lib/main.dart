import 'package:cxhub_sdk/cxhub_sdk.dart';
import 'package:cxhub_sdk_example/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CxHubSdk.init();
  CxHubSdk.collectEvent("AppCreate");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainScreen());
  }
}
