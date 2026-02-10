import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'screens/upload_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize(dismissPdfiumWasmWarnings: true);
  runApp(const DataHubApp());
}

class DataHubApp extends StatelessWidget {
  const DataHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1), brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const UploadScreen(),
    );
  }
}
