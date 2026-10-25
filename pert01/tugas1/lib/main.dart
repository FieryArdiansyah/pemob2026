import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartu Perkenalan',
      home: const IntroductionCard(),
    );
  }
}

class IntroductionCard extends StatelessWidget {
  const IntroductionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kartu Perkenalan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon
            const Icon(
              Icons.account_circle,
              size: 120,
              color: Colors.brown,
            ),

            const SizedBox(height: 20),

            // Nama
            const Text(
              'Fiery Ardiansyah',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),

            const SizedBox(height: 12),

            // NIM
            const Text(
              'NIM: 20240801092',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            // Jurusan
            const Text(
              'Jurusan: Teknik Informatika',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            // Hobi
            const Text(
              'Hobi: Lari dan Hiking',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}