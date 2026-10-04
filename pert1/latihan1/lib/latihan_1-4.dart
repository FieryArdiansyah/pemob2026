import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 1',
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Counter Saya',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flutter_dash,
              size: 80,
              color: Colors.black87,
            ),

            const SizedBox(height: 16),

            const Text(
              'Halo, nama saya Fiery!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
            ),

            const Text(
              'NIM: 20240801092',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              '$_count',
              style: const TextStyle(
                fontSize: 48,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tombol kurang
          FloatingActionButton(
            onPressed: () {
              if (_count > 0) {
                setState(() {
                  _count--;
                });
              }
            },
            child: const Icon(Icons.remove),
          ),

          const SizedBox(width: 10),

          // Tombol reset
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _count = 0;
              });
            },
            child: const Icon(Icons.refresh),
          ),

          const SizedBox(width: 10),

          // Tombol tambah
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _count++;
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}