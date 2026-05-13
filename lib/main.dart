import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  if (!kIsWeb) {
    await Hive.initFlutter();
  } else {
    await Hive.init('hive_boxes');
  }

  // Register adapters
  Hive.registerAdapter(ScanResultAdapter());

  // Open box eagerly
  await Hive.openBox<ScanResult>('scan_results');

  runApp(const AIScanSolveApp());
}

class AIScanSolveApp extends StatelessWidget {
  const AIScanSolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Scan & Solve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}