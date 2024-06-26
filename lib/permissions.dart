import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:io';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> RequestPermissionForAndroid() async {
  if (!Platform.isAndroid) {
    return;
  }
  PermissionStatus status = await Permission.location.status;

  if (status != PermissionStatus.granted) {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.nearbyWifiDevices.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothAdvertise.request();
  }
  if (!await NotificationListenerService.isPermissionGranted()) {
    // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
    await NotificationListenerService.requestPermission();
  }

  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // onNotificationPressed function to be called.
  //
  // When the notification is pressed while permission is denied,
  // the onNotificationPressed function is not called and the app opens.
  //
  // If you do not use the onNotificationPressed or launchApp function,
  // you do not need to write this code.
  if (!await FlutterForegroundTask.canDrawOverlays) {
    // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
    await FlutterForegroundTask.openSystemAlertWindowSettings();
  }

  // Android 12 or higher, there are restrictions on starting a foreground service.
  //
  // To restart the service on device reboot or unexpected problem, you need to allow below permission.
  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
  final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
}
