import 'package:flutter/widgets.dart';

class AppShadows {
  AppShadows._();
  static const sm = [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))];
  static const md = [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))];
  static const lg = [BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4))];
  static const xl = [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8))];
}
