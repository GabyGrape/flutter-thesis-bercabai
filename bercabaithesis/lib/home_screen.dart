import 'package:flutter/material.dart';
import 'dart:io'; // Untuk menangani file gambar
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk encode/decode JSON
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile; // Variabel untuk menyimpan foto yang diambil
  String _resultDiagnosis = "Belum ada diagnosis"; // Text hasil
  bool _isLoading = false; // Untuk loading spinner

  // --- FUNGSI LOGIKA: Mengirim Gambar ke FastAPI ---
  Future<void> _uploadImageAndGetPrediction() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true; // Tampilkan loading
      _resultDiagnosis = "Sedang menganalisis...";
    });

    try {
      // 1. GANTI IP INI SESUAI IP LAPTOP KAMU (Cek via ipconfig di CMD)
      // Jangan pakai localhost, pakai IP Wifi/LAN
      var ipAddress = "192.168.1.10"; // CONTOH, silakan ganti
      var uri = Uri.parse('http://$ipAddress:8000/predict');

      // 2. Buat request multipart (POST)
      var request = http.MultipartRequest('POST', uri);

      // 3. Masukkan file gambar dengan field name 'file' (sesuai FastAPI)
      request.files.add(
        await http.MultipartRequest.fromPath(
          'file',
          _imageFile!.path,
        ),
      );

      // 4. Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 5. Tangani respon
      if (response.statusCode == 200) {
        // Berhasil, decode JSON respon
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          _resultDiagnosis =
              "Penyakit: ${result['class']}\nConfidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%";
        });
      } else {
        setState(() {
          _resultDiagnosis = "Error Server: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultDiagnosis = "Koneksi Gagal: Pastikan IP benar & Server nyala\n$e";
      });
    } finally {
      setState(() {
        _isLoading = false; // Matikan loading
      });
    }
  }

  // Fungsi untuk berpindah ke halaman kamera
  Future<void> _navigateToCamera() async {
    // Tunggu hasil (file foto) dari CameraScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    // Jika user mengambil foto dan kembali
    if (result != null && result is String) {
      setState(() {
        _imageFile = File(result); // Simpan path foto sebagai file
        _resultDiagnosis = "Foto berhasil diambil. Siap dianalisis.";
      });
    }
  }

  // --- TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis Penyakit Cabai"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container Tampilan Gambar
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _imageFile == null
                  ? const Center(child: Text("Belum ada foto"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(height: 20),

            // Tombol Buka Kamera
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _navigateToCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Foto Daun"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Kirim ke Server
            ElevatedButton.icon(
              // Tombol mati jika tidak ada foto atau sedang loading
              onPressed: (_imageFile == null || _isLoading)
                  ? null
                  : _uploadImageAndGetPrediction,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Mulai Diagnosis"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 30),

            // Bagian Hasil Diagnosis
            const Divider(),
            const Text(
              "Hasil Analisis:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Tampilkan loading spinner atau text hasil
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Text(
                      _resultDiagnosis,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}