import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_ble_pro/util/encrypt.dart';
import 'package:flutter_ble_pro/widget/alert_dialog.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';

enum ExState {
  connected,
  findService,
  matchCharacter,
  startSession,
  sessionReady,
  cannotFindService,
  cannotMatchCharacter,
  sessionFail
}

class DeviceRow extends StatelessWidget {
  BluetoothDevice device;
  DeviceRow({super.key, required this.device});
  List<BluetoothService> needService = [];
  List<BluetoothCharacteristic> needCharacteristic = [];
  ValueNotifier<ExState> exStateNotifier = ValueNotifier(ExState.findService);
  ValueNotifier<List<int>> response = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
        value: device.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (_, __) {
          var state = _.watch<BluetoothDeviceState>();
          switch (state) {
            case BluetoothDeviceState.disconnected:
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(device.name),
                  TextButton(
                      onPressed: () async {
                        device.connect();
                      },
                      child: Text('连接')),
                ],
              );
            case BluetoothDeviceState.connecting:
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(device.name),
                  TextButton(onPressed: null, child: Text('连接中')),
                ],
              );
            case BluetoothDeviceState.connected:
              return MultiProvider(providers: [
                ChangeNotifierProvider.value(
                    value: exStateNotifier,
                    builder: (_, child) {
                      var exState = _.watch<ValueNotifier<ExState>>();
                      return ChangeNotifierProvider.value(
                          value: response,
                          builder: (_, child) {
                            var response = _.watch<ValueNotifier<List<int>>>();
                            return Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Text(_.watch<ExState>().toString()),
                                  Text(device.name),
                                  TextButton(
                                      onPressed: null, child: Text('已连接')),
                                  TextButton(
                                      onPressed: exState.value ==
                                              ExState.findService
                                          ? () async {
                                              //服务aec70173-6a2c-4350-9b8b-26b42cd34b80
                                              List<BluetoothService>
                                                  serviceList = await device
                                                      .discoverServices();
                                              needService = serviceList
                                                  .where((element) =>
                                                      element.uuid
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'aec70173-6a2c-4350-9b8b-26b42cd34b80')
                                                  .toList();
                                              if (needService.isNotEmpty) {
                                                exState.value =
                                                    ExState.matchCharacter;
                                              } else {
                                                exState.value =
                                                    ExState.cannotFindService;
                                              }
                                            }
                                          : null,
                                      child: Text('发现服务')),

                                  TextButton(
                                      onPressed: exState.value ==
                                              ExState.matchCharacter
                                          ? () async {
                                              //特征1842772a-4371-4960-a7bc-a5c70e06fb21

                                              needCharacteristic = needService[
                                                      0]
                                                  .characteristics
                                                  .where((element) =>
                                                      element.uuid
                                                          .toString()
                                                          .toLowerCase() ==
                                                      '1842772a-4371-4960-a7bc-a5c70e06fb21')
                                                  .toList();
                                              if (needService.isNotEmpty) {
                                                exState.value =
                                                    ExState.startSession;
                                              } else {
                                                exState.value = ExState
                                                    .cannotMatchCharacter;
                                              }
                                              bool setSuccess =
                                                  await needCharacteristic[0]
                                                      .setNotifyValue(true);
                                              if (setSuccess) {
                                                needCharacteristic[0]
                                                    .value
                                                    .listen((event) {
                                                  response.value =
                                                      aesDec128Decrypt(event);
                                                  print(
                                                      'raw response${event.map((e) => e.toRadixString(16))}');
                                                  print(
                                                      ' response${aesDec128Decrypt(event)}');
                                                });
                                              }
                                            }
                                          : null,
                                      child: Text('匹配特征')),

                                  TextButton(
                                      onPressed:
                                          exState.value == ExState.startSession
                                              ? () async {
                                                  //写入数据16进制50, 27, 2b, 33, c9, b8, 65, 85, 4f, 98, 11, 9c, 65, 4c, 82, f2
                                                  //EE,00,09,00,FE,25,46,7C,DC
                                                  //238,0,9,0,254,37,70,124,220
                                                  Uint8List encryted =
                                                      aesDec128Encrypt(
                                                          Uint8List.fromList([
                                                    238,
                                                    0,
                                                    9,
                                                    0,
                                                    254,
                                                    37,
                                                    70,
                                                    124,
                                                    220
                                                  ]));
                                                  needCharacteristic[0]
                                                      .write(encryted);
                                                }
                                              : null,
                                      child: Text('写入数据')),
                                  TextButton(
                                      onPressed: exState.value ==
                                              ExState.startSession
                                          ? () async {
                                              //写入数据16进制50, 27, 2b, 33, c9, b8, 65, 85, 4f, 98, 11, 9c, 65, 4c, 82, f2

                                              needCharacteristic[0].write([0]);
                                            }
                                          : null,
                                      child: Text('写入0')),
                                  Text(response.value.toString())
                                ]);
                          });
                    }),
              ]);
            case BluetoothDeviceState.disconnecting:
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(device.name),
                  TextButton(onPressed: null, child: Text('断开连接中')),
                ],
              );
            default:
              return nil;
          }
        });
  }
}
