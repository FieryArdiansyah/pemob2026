import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

// =====================================================
// MY APP
// =====================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Pengeluaran',
      home: PengeluaranPage(),
    );
  }
}

// =====================================================
// MODEL PENGELUARAN
// =====================================================

class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  // Mengubah object menjadi Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'kategori': kategori,
      'tanggal': tanggal,
    };
  }

  // Mengubah data SQLite menjadi object
  factory Pengeluaran.fromMap(
      Map<String, Object?> map,
      ) {
    return Pengeluaran(
      id: map['id'] as int,
      nama: map['nama'] as String,
      jumlah: map['jumlah'] as int,
      kategori: map['kategori'] as String,
      tanggal: map['tanggal'] as String,
    );
  }
}

// =====================================================
// DATABASE HELPER
// =====================================================

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final path = p.join(
      await getDatabasesPath(),
      'pengeluaran.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'nama TEXT NOT NULL, '
              'jumlah INTEGER NOT NULL, '
              'kategori TEXT NOT NULL, '
              'tanggal TEXT NOT NULL)',
        );
      },
    );

    return _db!;
  }

  // ===================================================
  // CREATE
  // ===================================================

  static Future<int> tambah(
      Pengeluaran pengeluaran,
      ) async {
    final db = await database;

    return db.insert(
      'pengeluaran',
      pengeluaran.toMap(),
    );
  }

  // ===================================================
  // READ
  // ===================================================

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;

    final data = await db.query(
      'pengeluaran',
      orderBy: 'id DESC',
    );

    return data
        .map(Pengeluaran.fromMap)
        .toList();
  }

  // ===================================================
  // UPDATE
  // ===================================================

  static Future<int> ubah(
      Pengeluaran pengeluaran,
      ) async {
    final db = await database;

    return db.update(
      'pengeluaran',
      pengeluaran.toMap(),
      where: 'id = ?',
      whereArgs: [pengeluaran.id],
    );
  }

  // ===================================================
  // DELETE
  // ===================================================

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// =====================================================
// HALAMAN PENGELUARAN
// =====================================================

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() =>
      _PengeluaranPageState();
}

class _PengeluaranPageState
    extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;

  bool _gelap = false;

  @override
  void initState() {
    super.initState();

    _future = DbHelper.semua();

    _muatPengaturan();
  }

  // ===================================================
  // SHAREDPREFERENCES
  // ===================================================

  Future<void> _muatPengaturan() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _gelap =
          prefs.getBool('gelap') ?? false;
    });
  }

  Future<void> _ubahTema(bool nilai) async {
    setState(() {
      _gelap = nilai;
    });

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'gelap',
      nilai,
    );
  }

  // ===================================================
  // MUAT DATA
  // ===================================================

  void _muat() {
    setState(() {
      _future = DbHelper.semua();
    });
  }

  // ===================================================
  // BUKA FORM
  // ===================================================

  Future<void> _bukaForm([
    Pengeluaran? pengeluaran,
  ]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(
          pengeluaran: pengeluaran,
        ),
      ),
    );

    if (!mounted) return;

    _muat();
  }

  // ===================================================
  // HAPUS DATA
  // ===================================================

  Future<void> _hapus(
      Pengeluaran pengeluaran,
      ) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Pengeluaran',
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus data ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    await DbHelper.hapus(
      pengeluaran.id!,
    );

    if (!mounted) return;

    _muat();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pengeluaran berhasil dihapus',
        ),
      ),
    );
  }

  // ===================================================
  // FORMAT RUPIAH
  // ===================================================

  String _rupiah(int angka) {
    final teks = angka.toString();
    final hasil = StringBuffer();

    for (int i = 0; i < teks.length; i++) {
      if (i > 0 &&
          (teks.length - i) % 3 == 0) {
        hasil.write('.');
      }

      hasil.write(teks[i]);
    }

    return 'Rp $hasil';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: _gelap
            ? Brightness.dark
            : Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pencatat Pengeluaran',
          ),

          actions: [
            Row(
              children: [
                const Icon(
                  Icons.dark_mode,
                ),

                Switch(
                  value: _gelap,
                  onChanged: _ubahTema,
                ),
              ],
            ),
          ],
        ),

        // =================================================
        // DAFTAR PENGELUARAN
        // =================================================

        body: FutureBuilder<List<Pengeluaran>>(
          future: _future,

          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                CircularProgressIndicator(),
              );
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                ),
              );
            }

            final data =
                snapshot.data ?? [];

            // Hitung total
            int total = 0;

            for (final item in data) {
              total += item.jumlah;
            }

            return Column(
              children: [
                // =======================================
                // TOTAL PENGELUARAN
                // =======================================

                Card(
                  margin: const EdgeInsets.all(12),

                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),

                    child: Column(
                      children: [
                        const Text(
                          'Total Pengeluaran',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _rupiah(total),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // =======================================
                // DATA KOSONG
                // =======================================

                if (data.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Belum ada pengeluaran',
                      ),
                    ),
                  )

                // =======================================
                // DAFTAR DATA
                // =======================================

                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,

                      itemBuilder:
                          (context, index) {
                        final item =
                        data[index];

                        return Card(
                          margin:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          child: ListTile(
                            title: Text(
                              item.nama,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              '${_rupiah(item.jumlah)} • '
                                  '${item.kategori}\n'
                                  '${item.tanggal}',
                            ),

                            isThreeLine: true,

                            onTap: () {
                              _bukaForm(item);
                            },

                            trailing:
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                              ),
                              onPressed: () {
                                _hapus(item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),

        // =================================================
        // TOMBOL TAMBAH
        // =================================================

        floatingActionButton:
        FloatingActionButton(
          onPressed: () => _bukaForm(),

          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// FORM PENGELUARAN
// =====================================================

class FormPengeluaranPage
    extends StatefulWidget {
  final Pengeluaran? pengeluaran;

  const FormPengeluaranPage({
    super.key,
    this.pengeluaran,
  });

  @override
  State<FormPengeluaranPage> createState() =>
      _FormPengeluaranPageState();
}

class _FormPengeluaranPageState
    extends State<FormPengeluaranPage> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _jumlah;

  String? _kategori;

  final List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    _nama = TextEditingController(
      text: widget.pengeluaran?.nama ?? '',
    );

    _jumlah = TextEditingController(
      text: widget.pengeluaran != null
          ? widget.pengeluaran!.jumlah
          .toString()
          : '',
    );

    _kategori =
        widget.pengeluaran?.kategori;
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();

    super.dispose();
  }

  // ===================================================
  // SIMPAN
  // ===================================================

  Future<void> _simpan() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final jumlah =
    int.tryParse(
      _jumlah.text.trim(),
    );

    if (jumlah == null ||
        jumlah <= 0) {
      return;
    }

    final pengeluaran =
    Pengeluaran(
      id: widget.pengeluaran?.id,

      nama: _nama.text.trim(),

      jumlah: jumlah,

      kategori: _kategori!,

      tanggal: widget.pengeluaran
          ?.tanggal ??
          _tanggalHariIni(),
    );

    // Tambah
    if (widget.pengeluaran == null) {
      await DbHelper.tambah(
        pengeluaran,
      );
    }

    // Edit
    else {
      await DbHelper.ubah(
        pengeluaran,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ===================================================
  // TANGGAL
  // ===================================================

  String _tanggalHariIni() {
    final sekarang = DateTime.now();

    final hari =
    sekarang.day
        .toString()
        .padLeft(2, '0');

    final bulan =
    sekarang.month
        .toString()
        .padLeft(2, '0');

    final tahun =
    sekarang.year.toString();

    return '$hari-$bulan-$tahun';
  }

  @override
  Widget build(BuildContext context) {
    final baru =
        widget.pengeluaran == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru
              ? 'Tambah Pengeluaran'
              : 'Edit Pengeluaran',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [
            // =========================================
            // NAMA
            // =========================================

            TextFormField(
              controller: _nama,

              decoration:
              const InputDecoration(
                labelText:
                'Nama pengeluaran',
                border:
                OutlineInputBorder(),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // =========================================
            // JUMLAH
            // =========================================

            TextFormField(
              controller: _jumlah,

              keyboardType:
              TextInputType.number,

              decoration:
              const InputDecoration(
                labelText:
                'Jumlah pengeluaran',
                prefixText: 'Rp ',
                border:
                OutlineInputBorder(),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final angka =
                int.tryParse(
                  value.trim(),
                );

                if (angka == null) {
                  return 'Jumlah harus berupa angka';
                }

                if (angka <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // =========================================
            // KATEGORI
            // =========================================

            DropdownButtonFormField<String>(
              value: _kategori,

              decoration:
              const InputDecoration(
                labelText: 'Kategori',
                border:
                OutlineInputBorder(),
              ),

              items: _kategoriList
                  .map(
                    (kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(
                      kategori,
                    ),
                  );
                },
              )
                  .toList(),

              onChanged: (value) {
                setState(() {
                  _kategori = value;
                });
              },

              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Kategori wajib dipilih';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // =========================================
            // TOMBOL SIMPAN
            // =========================================

            SizedBox(
              height: 50,

              child: ElevatedButton(
                onPressed: _simpan,

                child: Text(
                  baru
                      ? 'Tambah Pengeluaran'
                      : 'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}