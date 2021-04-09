package com.ace.plugin.flutter_app07;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import android.util.Log;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import androidx.core.app.NotificationCompat;
import com.alibaba.fastjson.JSONObject;

public class MainActivity extends FlutterActivity {
    private MethodChannel.Result mResult;

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (intent != null && intent.getExtras() != null && intent.getExtras().containsKey("push_extras")) {
            String extras = intent.getStringExtra("push_extras");
            if (mResult != null) {
                mResult.success(extras);
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
            "com.ace.plugin.flutter_app/tpns_notification").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call != null && call.method.equals("tpns_extras")) {
                    setNotification(MainActivity.this, call.arguments.toString());
                    mResult = result;
                } else {
                    result.notImplemented();
                }
            }
        });
    }

    private void setNotification(Context context, String extras) {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel =
                new NotificationChannel("ace_push", "ace_push_name", NotificationManager.IMPORTANCE_HIGH);
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
        int notificationId = new java.util.Random().nextInt(1000);

        //Intent intent = new Intent(MainActivity.this, TPNSNotificationReceiver.class);
        //PendingIntent pendingIntent = PendingIntent.getBroadcast(MainActivity.this, 101, intent, 102);
        Intent intent = new Intent(context, MainActivity.class);
        intent.putExtra("push_extras", extras);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent pendingIntent =
            PendingIntent.getActivity(context, notificationId, intent, PendingIntent.FLAG_CANCEL_CURRENT);
        JSONObject json = JSONObject.parseObject(extras);
        String extrasStr = json.getString("extras");
        json = JSONObject.parseObject(extrasStr);
        String title = json.getString("title");
        String desc = json.getString("desc");
        Notification notification = new NotificationCompat.Builder(context, "ace_push").setContentTitle(title)
            .setContentText(desc)
            .setContentIntent(pendingIntent)
            .setWhen(System.currentTimeMillis())
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .build();
        notificationManager.notify(notificationId, notification);
    }
}
