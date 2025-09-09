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
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController(text: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjZDODBDMjc5MUZBMEVCODczMDI2NzlFRDhFQzFDRTE5OTNEQTAwMjMiLCJ4NXQiOiJiSURDZVItZzY0Y3dKbm50anNIT0daUGFBQ00iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjNkYzQ1Njg5LWFhNTYtNDE1YS1iYjAxLTcwNzM4ZTljZWQyYV8wMDAwMDAyOS1jY2Y5LTRiZDAtMDM0My01YzNhMGQwMDNkNGIiLCJzY3AiOjE3OTIsImNzaSI6IjE3NTczOTgxNDkiLCJleHAiOjE3NTc0ODQ1NDksInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6ImNoYXQsdm9pcCIsInJlc291cmNlSWQiOiIzZGM0NTY4OS1hYTU2LTQxNWEtYmIwMS03MDczOGU5Y2VkMmEiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNzU3Mzk4MTQ5fQ.VHUnGTYGJlFOzqQLqRO6S59t4YO8GZlRqroxP-O3QlaHxMd9ULLKg0O1J5DWHbiafZ3aDD1bKr7qrdXSgP84YhUl7wW_7uEVkWH-wH6UU4thoJPJDam9g4IDB36wmtKZUfvMFAlMmLAcnMkieToQalbIJUsmSc1JI027fGLGqAmTz3MGIGbOwKFRurIesUfbWladwsvBs3V2Gcrr-ATkytW7Z2dyIdioV0qYEeg3fU7_knumEADpu6lqiU2P5CKb4d9WFe4PziphUlDzEaKpT7c2037-3DURBEAMfg963Y4xDKpKt7pT9gKGz3YaD1YBfitZ_UVWMlwsLJVq4TmG4g");
  final _meetingCtrl = TextEditingController();
  final _meetingTitleCtrl = TextEditingController(text: "Appointment 10");
  final _nameCtrl = TextEditingController(text: 'Test User');

  final _azureCalling = AzureCalling();

  bool skipSetupScreen=false,cameraOn=false,microphoneOn=false;



  void updateSkipSetupScreen(bool value){
    skipSetupScreen =value;
    setState(() {

    });
  }

  void updateCameraOn(bool value){
    cameraOn =value;
    setState(() {

    });
  }
  void updateMicrophoneOn(bool value){
    microphoneOn =value;
    setState(() {

    });
  }
  @override
  void dispose() {
    _tokenCtrl.dispose();
    _meetingCtrl.dispose();
    _meetingTitleCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pasteTo(TextEditingController c) async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) c.text = data!.text!;
  }

  void _startCall() {
    if (!_formKey.currentState!.validate()) return;
    _azureCalling.startCall(
      token: _tokenCtrl.text.trim(),
      meetingLink: _meetingCtrl.text.trim(),
      displayName: _nameCtrl.text.trim(),
      title: "Appointment 20",
      subTitle: "Dr Mohammed Ali",
      cameraOn: cameraOn,
      microphoneOn: microphoneOn,
      skipSetupScreen: skipSetupScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('ACS Calling – Start Call')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Token (multiline, with Paste button)
                  AppFormField(
                    controller: _tokenCtrl,
                    label: 'Access Token (JWT)',
                    hint: 'Paste your ACS access token',
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Token is required';
                      if (!s.contains('.')) return 'Looks like an invalid JWT';
                      return null;
                    },
                    suffix: IconButton(
                      tooltip: 'Paste',
                      icon: const Icon(Icons.paste),
                      onPressed: () => _pasteTo(_tokenCtrl),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meeting link
                  AppFormField(
                    controller: _meetingCtrl,
                    label: 'Meeting link',
                    hint: 'https://teams.microsoft.com/meet/…',
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Meeting link is required';
                      if (!s.startsWith('http')) return 'Enter a valid URL';
                      return null;
                    },
                    prefix: const Icon(Icons.link),
                  ),
                  const SizedBox(height: 12),

                  // Display name
                  AppFormField(
                    controller: _nameCtrl,
                    label: 'Display name',
                    hint: 'Your name in the call',
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [LengthLimitingTextInputFormatter(60)],
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Display name is required' : null,
                    prefix: const Icon(Icons.person),
                  ),
                  const SizedBox(height: 20),

                  Row(children: [

                    Expanded(flex: 2,child: SwitchListTile(title: Text("Skip Setup Screen"),value: skipSetupScreen, onChanged: updateSkipSetupScreen,dense: true,contentPadding: EdgeInsets.zero,)),

                  ],),

                  SizedBox(height: 20,),
                  Row(children: [

                    // Expanded(flex: 2,child: SwitchListTile(title: Text("Skip Setup Screen"),value: skipSetupScreen, onChanged: updateSkipSetupScreen,dense: true,)),
                    Expanded(child: SwitchListTile(title: Text("Camera"),value: cameraOn, onChanged: updateCameraOn,dense: true,contentPadding: EdgeInsets.zero,)),
                    SizedBox(width: 50,),
                    Expanded(child: SwitchListTile(title: Text("Microphone"),value: microphoneOn, onChanged: updateMicrophoneOn,dense: true,contentPadding: EdgeInsets.zero,)),

                  ],),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startCall,
                      icon: const Icon(Icons.call),
                      label: const Text('Start Call'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? minLines;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? 1 : minLines,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: prefix,
        suffixIcon: suffix,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

