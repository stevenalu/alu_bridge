import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class AluBridgeApp extends StatelessWidget {
  const AluBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Bridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(body: SizedBox.shrink()),
    );
  }
}
