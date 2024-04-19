import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../controllers/device_controller.dart';

// TODO remove 4 replace with service

Future<void> findMyPhoneService(BluetoothService findMyPhoneService) async {
  final ApplicationController controller = Get.find();
  BluetoothCharacteristic findMyPhoneCharacteristic =
      findMyPhoneService.characteristics[4];
  controller.setFindMyPhoneService(findMyPhoneCharacteristic);

//Subscribe event
  await findMyPhoneCharacteristic.setNotifyValue(true);
  try {
    await findMyPhoneCharacteristic.lastValueStream.listen((event) {
      print(event);
    });
  } catch (e) {
    print("error: " + e.toString());
  }
}
