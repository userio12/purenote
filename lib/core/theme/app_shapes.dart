import 'package:flutter/widgets.dart';

class AppShapes {
  AppShapes._();
  static const none = BorderRadius.zero;
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));

  static const smTop = BorderRadius.vertical(top: Radius.circular(8));
  static const lgTop = BorderRadius.vertical(top: Radius.circular(16));
  static const xlTop = BorderRadius.vertical(top: Radius.circular(24));
}
