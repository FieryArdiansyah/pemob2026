import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pengaturan extends ChangeNotifier {
  bool gelap = false;

  int target = 20000;

  int warna = Colors.blue.toARGB32();

  Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();

    gelap = prefs.getBool('gelap') ?? false;

    target = prefs.getInt('target') ?? 20000;

    warna =
        prefs.getInt('warna') ??
            Colors.blue.toARGB32();

    notifyListeners();
  }

  Future<void> setGelap(bool value) async {
    gelap = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'gelap',
      value,
    );

    notifyListeners();
  }

  Future<void> setTarget(int value) async {
    target = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'target',
      value,
    );

    notifyListeners();
  }

  Future<void> setWarna(Color value) async {
    warna = value.toARGB32();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'warna',
      warna,
    );

    notifyListeners();
  }
}

final pengaturan = Pengaturan();