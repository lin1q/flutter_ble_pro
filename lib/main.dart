import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ble_pro/api.dart';
import 'package:flutter_ble_pro/page/main_page.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Provider(
          create: (_) => StreamController<List<ScanResult>>(),
          builder: (_, __) {
            var scanNeedResult = _.watch<StreamController<List<ScanResult>>>();
            return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: BLEMainPage(),
                ),
                floatingActionButton: StreamProvider.value(
                  value: flutterBlue.isScanning,
                  initialData: false,
                  builder: (_, __) {
                    var isScanning = _.watch<bool>();
                    return isScanning
                        ? FloatingActionButton(
                            onPressed: () {
                              flutterBlue.stopScan();
                            },
                            child: Icon(Icons.stop))
                        : FloatingActionButton(
                            onPressed: () {
                              scan(scanNeedResult);
                            },
                            child: Icon(Icons.search));
                  },
                ));
          }),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
