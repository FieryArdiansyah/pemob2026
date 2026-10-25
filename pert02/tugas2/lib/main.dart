import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Kontak {
  final String nama;
  final String nomor;
  final String email;

  const Kontak(this.nama, this.nomor, this.email);
}

const daftarKontak = [
  Kontak(
    'Fiery',
    '081234567890',
    'fiery@gmail.com',
  ),
  Kontak(
    'Spidy',
    '081298765432',
    'spidy@gmail.com',
  ),
  Kontak(
    'Budi Santoso',
    '082112345678',
    'budi@gmail.com',
  ),
  Kontak(
    'Citra Lestari',
    '085612345678',
    'citra@gmail.com',
  ),
  Kontak(
    'Dimas Pratama',
    '081377889900',
    'dimas@gmail.com',
  ),
  Kontak(
    'Fajar Ramadhan',
    '089876543210',
    'fajar@gmail.com',
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
      ),
      home: const KontakPage(),
    );
  }
}

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text(
                kontak.nama[0],
              ),
            ),
            title: Text(kontak.nama),
            subtitle: Text(kontak.nomor),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailKontakPage(
                    kontak: kontak,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;

  const DetailKontakPage({
    super.key,
    required this.kontak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontak'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(
                  kontak.nama[0],
                  style: const TextStyle(
                    fontSize: 36,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                kontak.nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Nomor Telepon',
                style: TextStyle(
                  color: Colors.brown.shade600,
                ),
              ),

              Text(
                kontak.nomor,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Email',
                style: TextStyle(
                  color: Colors.brown.shade600,
                ),
              ),

              Text(
                kontak.email,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}