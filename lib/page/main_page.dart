import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ble_pro/widget/device_row.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';

class BLEMainPage extends StatefulWidget {
  BLEMainPage({super.key});

  @override
  BLEMainPageState createState() => BLEMainPageState();
}

class BLEMainPageState extends State<BLEMainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        StreamBuilder<List<ScanResult>>(
            stream: context.watch<StreamController<List<ScanResult>>>().stream,
            initialData: const <ScanResult>[],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      var device = snapshot.data![index].device;
                      return DeviceRow(
                        device: device,
                      );
                    });
              } else {
                return Text('nodata');
              }
            })
      ],
    );
  }
}
