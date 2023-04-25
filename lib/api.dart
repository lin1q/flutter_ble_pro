import 'dart:async';
import 'dart:io';

import 'package:flutter_ble_pro/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ble_pro/widget/alert_dialog.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:location/location.dart';

FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
Location location = Location();
Future<void> scan(StreamController<List<ScanResult>> controller) async {
  if (!await requestPermission()) {
    _toShowAlert('没有权限', '');
  } else {
    if (await _toShowAlertAccordingService()) {
      return;
    }
  }
  // Start scanning
  await flutterBlue.startScan(timeout: Duration(seconds: 4));

  flutterBlue.scanResults.listen((results) {
    // do something with scan results
    List<ScanResult> needResult = checkIsNeedDevice(results);
    controller.add(needResult);
  });
}

//过滤扫描设备，比如根据前缀，只需要eamy开头的设备
List<ScanResult> checkIsNeedDevice(List<ScanResult> result) {
  List<ScanResult> needResult = result
      .where((element) => element.device.name.startsWith('eamy'))
      .toList();
  return needResult;
}

enum ServiceStatus { allOpen, openBle, openGPS, allClose }

Future<ServiceStatus> checkService() async {
  bool ble = await flutterBlue.isOn;
  bool gps = await location.serviceEnabled();
  if (ble && gps) {
    return ServiceStatus.allOpen;
  } else if (!ble && gps) {
    return ServiceStatus.openGPS;
  } else if (ble && !gps) {
    return ServiceStatus.openBle;
  } else {
    return ServiceStatus.allClose;
  }
}

Future<bool> _toShowAlertAccordingService() async {
  ServiceStatus status = await checkService();
  await Future.delayed(Duration(seconds: 0)).then((onValue) async {
    BuildContext context = navigatorKey.currentState!.overlay!.context;
    switch (status) {
      case ServiceStatus.allClose:
        showAlertDialog(context, '请打开蓝牙和定位', '');
        await requestLocationService();
        return true;

      case ServiceStatus.allOpen:
        return false;

      case ServiceStatus.openBle:
        showAlertDialog(context, '请打开定位', '');
        await requestLocationService();
        return true;

      case ServiceStatus.openGPS:
        showAlertDialog(context, '请打开蓝牙', '');
        return true;
    }
  });
  return false;
}

_toShowAlert(String title, String text) async {
  await Future.delayed(Duration(seconds: 0)).then((onValue) {
    BuildContext context = navigatorKey.currentState!.overlay!.context;
    showAlertDialog(context, title, text);
  });
}

Future<bool> requestPermission() async {
  PermissionStatus currentLocation = await location.requestPermission();
  if (currentLocation != PermissionStatus.granted &&
      currentLocation != PermissionStatus.grantedLimited) {
    return false;
  }
  return true;
}

requestLocationService() async {
  bool isOpenLocation = await location.requestService();
}
