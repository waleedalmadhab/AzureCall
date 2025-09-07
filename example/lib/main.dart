import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:azure_calling/azure_calling.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _azureCallingPlugin = AzureCalling();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _azureCallingPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              SizedBox(height: 30,),
              ElevatedButton(onPressed: (){

                startCall();

              }, child: Text("Start Call")),
            ],
          ),
        ),
      ),
    );
  }

  void startCall() {
    String token ="eyJhbGciOiJSUzI1NiIsImtpZCI6IjZDODBDMjc5MUZBMEVCODczMDI2NzlFRDhFQzFDRTE5OTNEQTAwMjMiLCJ4NXQiOiJiSURDZVItZzY0Y3dKbm50anNIT0daUGFBQ00iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjNkYzQ1Njg5LWFhNTYtNDE1YS1iYjAxLTcwNzM4ZTljZWQyYV8wMDAwMDAyOS1jMmQ3LTVkZTItMGUwNC0zNDNhMGQwMGIxZDAiLCJzY3AiOjE3OTIsImNzaSI6IjE3NTcyMjgxNTMiLCJleHAiOjE3NTczMTQ1NTMsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAiLCJyZXNvdXJjZUlkIjoiM2RjNDU2ODktYWE1Ni00MTVhLWJiMDEtNzA3MzhlOWNlZDJhIiwicmVzb3VyY2VMb2NhdGlvbiI6InVuaXRlZHN0YXRlcyIsImlhdCI6MTc1NzIyODE1M30.A-MgDe92xl_5dhwT__tmKG5TsKzBtcTIvUQGhDMJyxowi7GE1Pf9DEDbynMLS3r7eg9hOUzcoTvya6NQJmbeEDZHK5GqkvfWYCJ8USM0BVdoxfGMVBY0ufMauZvo-hBCIkMyJC9sfBgHlpVCqvm2rkahYWCRgfbe5fN062UV7PSv4VaEBy8g0g9DyTgo7QCVnQD1ERY8_e_J_DpMu6x_9S_ytyFp1WRUB2sCUPhgi0_dS8Xg2PuYox_86rBDdnM1_Vr3BAQJfgDKxfC24IAykJmUDRNhAF-nQAqqaGloXVZ-rNqIm3vOYBjaldjlV4vOXpRnncXFD17OyDnbIgw0ig";
    String meetingLink ="https://teams.microsoft.com/meet/3141468473165?p=SqKG7vRp3L2qjtFbIm";
    _azureCallingPlugin.startCall(token: token, meetingLink: meetingLink, displayName: "Waleed Test");

  }
}
