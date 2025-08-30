import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes() async {
    // Contoh: lokasi Jakarta
    final url = Uri.parse(
        "https://api.aladhan.com/v1/timingsByCity?city=Jakarta&country=Indonesia&method=2");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        prayerTimes = data['data']['timings'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception("Gagal memuat data waktu shalat");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waktu Shalat")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : prayerTimes == null
              ? const Center(child: Text("Gagal memuat data"))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    PrayerTile("Subuh", prayerTimes!["Fajr"]),
                    PrayerTile("Dzuhur", prayerTimes!["Dhuhr"]),
                    PrayerTile("Ashar", prayerTimes!["Asr"]),
                    PrayerTile("Maghrib", prayerTimes!["Maghrib"]),
                    PrayerTile("Isya", prayerTimes!["Isha"]),
                  ],
                ),
    );
  }
}

class PrayerTile extends StatelessWidget {
  final String name;
  final String time;

  const PrayerTile(this.name, this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.green),
        title: Text(name, style: const TextStyle(fontSize: 18)),
        trailing: Text(time, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
