import 'dart:io';
import 'dart:isolate';

import 'package:Nebula/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

import '../controllers/device_controller.dart';
import '../main.dart';
import '../permission_helper.dart';

class BackgroundHandler extends TaskHandler {
  SendPort? _sendPort;
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
    ApplicationController controller = ApplicationController();
    Get.put(controller);
    connectToDevice();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
    );

    _sendPort?.send('SONO UN MESSAGIO DAL BACKGROUND');
    //TODO Listen for connection
    // main();
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    //TODO implement this
    // FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class BackGroundNotification extends StatefulWidget {
  const BackGroundNotification({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BackGroundNotificationState();
}

class BackGroundNotificationState extends State<BackGroundNotification> {
  ReceivePort? _receivePort;

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'assets/images/icon.png',
          backgroundColor: Color.fromARGB(0, 166, 0, 255),
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
        print('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        print('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestPermissionForAndroid();
      _initForegroundTask();
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      } else {
        _startForegroundTask();
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  Future<bool> _startForegroundTask() async {
    await FlutterForegroundTask.saveData(
        key: 'customData', value: 'SOLGALEOOOOOOO');
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(child: _buildContentView());
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // buttonBuilder('start', onPressed: _startForegroundTask),
          // buttonBuilder('stop', onPressed: _stopForegroundTask),
        ],
      ),
    );
  }
}
