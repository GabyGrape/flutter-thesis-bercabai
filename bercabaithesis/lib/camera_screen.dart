import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// Impor variabel global cameras dari main.dart
import 'main.dart'; 

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Gunakan kamera pertama (biasanya kamera belakang)
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium, // Kualitas medium biar gak keberatan pas kirim
      );

      // Inisialisasi controller
      _initializeControllerFuture = _controller.initialize();
    }
  }

  @override
  void dispose() {
    // Dispose controller saat halaman ditutup biar gak boros batre
    _controller.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil foto
  Future<void> _takePicture() async {
    if (_initializeControllerFuture == null) return;

    try {
      // Pastikan inisialisasi selesai
      await _initializeControllerFuture;

      // Ambil foto (hasilnya disimpan di path temporary)
      final image = await _controller.takePicture();

      if (!mounted) return;

      // Kembali ke HomeScreen dan kirim path gambar
      Navigator.pop(context, image.path);
    } catch (e) {
      print("Error mengambil foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Kamera tidak ditemukan")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Tema gelap untuk kamera
      appBar: AppBar(
        title: const Text("Arahkan ke Daun"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Tampilan Preview Kamera
            return Stack(
              children: [
                Center(child: CameraPreview(_controller)),
                // Tambahkan overlay target di tengah agar user fokus
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            );
          } else {
            // Tampilan Loading saat inisialisasi
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // Tombol Shutter (Ambil Foto)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: Colors.white,
        child: const Icon(Icons.circle, color: Colors.grey, size: 50),
      ),
    );
  }
}