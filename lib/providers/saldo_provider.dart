import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class SaldoProvider extends ChangeNotifier {
  double _saldo = 0.0;

  double get saldo => _saldo;

  Future<void> loadSaldo() async {
  final result = await ApiService.getUserDetail();
  if (result['success']) {
    final user = result['data'];
    _saldo = double.tryParse(user['saldo'].toString()) ?? 0.0;
  } else {
    _saldo = 0.0;
  }
  notifyListeners();
}

  Future<void> updateSaldo(double newSaldo) async {
    final prefs = await SharedPreferences.getInstance();
    _saldo = newSaldo;
    await prefs.setDouble('saldo', newSaldo);
    notifyListeners();
  }
}
