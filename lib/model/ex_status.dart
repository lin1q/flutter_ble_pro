import 'package:flutter/material.dart';
import 'package:flutter_ble_pro/widget/device_row.dart';

class ExStatusModel with ChangeNotifier {
  ExState _status = ExState.connected;

  ExState get status => _status;

  void updateByService() {
    _status = ExState.findService;
    notifyListeners();
  }
}
