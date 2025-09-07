package com.sm.azure_calling;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import java.util.concurrent.Callable;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.azure.android.communication.common.CommunicationTokenCredential;
import com.azure.android.communication.common.CommunicationTokenRefreshOptions;
import com.azure.android.communication.ui.calling.CallComposite;
import com.azure.android.communication.ui.calling.CallCompositeBuilder;
import com.azure.android.communication.ui.calling.models.CallCompositeJoinLocator;
import com.azure.android.communication.ui.calling.models.CallCompositeTeamsMeetingLinkLocator;

public class AzureCallingPlugin implements
        FlutterPlugin,
        MethodChannel.MethodCallHandler,
        ActivityAware {

  private MethodChannel channel;
  private Context applicationContext;   // <-- app context for builders
  private Activity activity;            // <-- activity for launch()

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), "azure_calling");
    channel.setMethodCallHandler(this);
  }

  // ActivityAware
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
      return;
    }

    if (call.method.equals("startCall")) {
      // Expecting args from Dart: { token: "...", meetingLink: "...", displayName: "..." }
      String token = null;
      String meetingLink = null;
      String displayName = null;
      if (call.arguments instanceof Map) {
        Map<?, ?> args = (Map<?, ?>) call.arguments;
        token = (String) args.get("token");
        meetingLink = (String) args.get("meetingLink");
        displayName = (String) args.get("displayName");
      }

      try {
        startCall(token, meetingLink, displayName);
        result.success(null);
      } catch (Exception e) {
        result.error("START_CALL_FAILED", e.getMessage(), null);
      }
      return;
    }

    result.notImplemented();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    applicationContext = null;
  }

  private void startCall(String token, String meetingLink, String displayName) {
    if (applicationContext == null) throw new IllegalStateException("Application context is null");
    if (activity == null) throw new IllegalStateException("Activity is null (plugin must be attached to an Activity)");

    CommunicationTokenRefreshOptions refreshOptions =
            new CommunicationTokenRefreshOptions(
                    (Callable<String>) () -> token,
                    true
            );

    CommunicationTokenCredential credential =
            new CommunicationTokenCredential(refreshOptions);

    CallCompositeJoinLocator locator =
            new CallCompositeTeamsMeetingLinkLocator(meetingLink);

    CallComposite callComposite = new CallCompositeBuilder()
            .applicationContext(applicationContext)   // <-- use app context here
            .credential(credential)
            .displayName(displayName)
            .build();

    callComposite.addOnErrorEventHandler(e -> {
      Log.e("ACS_UI", "Join error: " + e.getErrorCode(), e.getCause());
    });

    // Launch must use an Activity; do it on UI thread for safety
    activity.runOnUiThread(() -> callComposite.launch(activity, locator));
  }
}
