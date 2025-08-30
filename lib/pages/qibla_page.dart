import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QiblaPage extends StatefulWidget {
  const QiblaPage({Key? key}) : super(key: key);

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  double? _qiblaDirection;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getQiblaDirection();
  }

  Future<void> _getQiblaDirection() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Izin lokasi ditolak';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.';
          _loading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final response = await http.get(Uri.parse('https://api.aladhan.com/v1/qibla/${position.latitude}/${position.longitude}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _qiblaDirection = data['data']['direction']?.toDouble();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal mendapatkan data dari API';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal mendapatkan lokasi atau data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : _qiblaDirection != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore, size: 80, color: Colors.green),
                          const SizedBox(height: 20),
                          Text('Arah Kiblat: ${_qiblaDirection!.toStringAsFixed(2)}° dari utara'),
                        ],
                      )
                    : const Text('Tidak ada data'),
      ),
    );
  }
}
