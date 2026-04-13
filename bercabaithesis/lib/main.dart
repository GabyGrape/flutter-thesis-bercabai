import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home_screen.dart';

// Variabel global untuk menampung daftar kamera
List<CameraDescription> cameras = [];

Future<void> main() async {
  // Pastikan plugin Flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Ambil daftar kamera yang tersedia di perangkat
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error menginisialisasi kamera: $e');
  }

  runApp(const BercabaiApp());
}

class BercabaiApp extends StatelessWidget {
  const BercabaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bercabai Thesis',
      theme: ThemeData(
        // Pakai warna hijau biar tema pertanian
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}