import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_scratch_page.dart';

void main() {
  runApp(const AluBridgeApp());
}

class AluBridgeApp extends StatelessWidget {
  const AluBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Bridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ThemeScratchPage(),
    );
  }
}
