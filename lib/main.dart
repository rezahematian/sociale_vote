import 'package:flutter/material.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'home/public_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppBootstrap.init();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PublicHomeScreen(),
    ),
  );
}
