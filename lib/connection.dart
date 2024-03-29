import 'package:Nebula/utils/extra.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/device_controller.dart';
import 'services/init_services.dart';
import 'utils/snackbar.dart';
import 'package:get/get.dart';

Future<void> connectToDevice() async {
  final ApplicationController controller = Get.find();
  bool isPermissionGranted =
      await NotificationListenerService.isPermissionGranted();

  if (!isPermissionGranted) {
    await NotificationListenerService.requestPermission();
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('uuid') ?? "";
    final deviceName = prefs.getString('deviceName') ?? "";

    if (uuid.isNotEmpty && deviceName.isNotEmpty) {
      controller.setDeviceInfoName(deviceName);
      controller.myDevice.value =
          BluetoothDevice(remoteId: DeviceIdentifier(uuid));
      await controller.myDevice.value.connectAndUpdateStream();

      controller.setDevice(controller.myDevice.value);
      /*  setState(() {
        controller.myDevice.value = controller.myDevice.value;
      }); */

      FlutterForegroundTask.saveData(key: 'uuid', value: uuid);

      FlutterForegroundTask.saveData(
          key: 'deviceName', value: controller.myDeviceInfo.value.deviceName);

      FlutterForegroundTask.saveData(key: 'isConnected', value: true);

      initServices();
    } else {
      Snackbar.show(ABC.c, "UUID or Device Name is empty", success: false);
    }
  } catch (e) {
    Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
  }
  await Future.delayed(Duration(seconds: 1));
}

Future<void> getMyData() async {
  final ApplicationController controller = Get.find();
  final Map<String, Object> myData = await FlutterForegroundTask.getAllData();
  int? myBattery = int.tryParse(myData["myBattery"].toString());
  controller.setDeviceInfoBattery(myBattery!);

  controller.setDeviceInfoAddress(myData["uuid"].toString());
  controller.setDeviceInfoName(myData["deviceName"].toString());
  controller
      .setDeviceInfoIsConnected(bool.parse(myData["isConnected"].toString()));
}
