
import 'package:flutter/services.dart';


class AzureCalling {

  final methodChannel = const MethodChannel('azure_calling');





  Future<void> startCall({required String token,required String meetingLink,required String displayName}) async {
     await methodChannel.invokeMethod<void>('startCall',{"token":token,"meetingLink":meetingLink,"displayName":displayName});
  }

  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
