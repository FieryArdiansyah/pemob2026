import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Latihan Catatan',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const CatatanPage(),
    );
  }
}

// =====================================================
// MODEL CATATAN
// =====================================================

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String dibuat;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.dibuat,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'dibuat': dibuat,
    };
  }

  factory Catatan.fromMap(
      Map<String, Object?> map,
      ) {
    return Catatan(
      id: map['id'] as int,
      judul: map['judul'] as String,
      isi: map['isi'] as String,

      // Data lama mungkin belum memiliki tanggal
      dibuat: map['dibuat'] as String? ?? '-',
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
      'catatan_latihan.db',
    );

    _db = await openDatabase(
      path,

      // ===============================================
      // VERSION 2
      // ===============================================

      version: 2,

      // ===============================================
      // DATABASE BARU
      // ===============================================

      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'judul TEXT NOT NULL, '
              'isi TEXT NOT NULL, '
              'dibuat TEXT)',
        );
      },

      // ===============================================
      // DATABASE LAMA -> DATABASE BARU
      // ===============================================

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE catatan '
                'ADD COLUMN dibuat TEXT',
          );
        }
      },
    );

    return _db!;
  }

  // ===================================================
  // TAMBAH
  // ===================================================

  static Future<int> tambah(
      Catatan catatan,
      ) async {
    final db = await database;

    return db.insert(
      'catatan',
      catatan.toMap(),
    );
  }

  // ===================================================
  // TAMPILKAN + PENCARIAN + URUTAN
  // ===================================================

  static Future<List<Catatan>> semua({
    String kata = '',
    bool terbaru = true,
  }) async {
    final db = await database;

    final data = await db.query(
      'catatan',

      // ===============================================
      // LATIHAN 2: SEARCH
      // ===============================================

      where: kata.trim().isEmpty
          ? null
          : 'judul LIKE ?',

      whereArgs: kata.trim().isEmpty
          ? null
          : ['%${kata.trim()}%'],

      // ===============================================
      // LATIHAN 4: SORTING
      // ===============================================

      orderBy:
      terbaru ? 'id DESC' : 'id ASC',
    );

    return data
        .map(Catatan.fromMap)
        .toList();
  }

  // ===================================================
  // UBAH
  // ===================================================

  static Future<int> ubah(
      Catatan catatan,
      ) async {
    final db = await database;

    return db.update(
      'catatan',
      catatan.toMap(),

      where: 'id = ?',

      whereArgs: [
        catatan.id,
      ],
    );
  }

  // ===================================================
  // HAPUS
  // ===================================================

  static Future<int> hapus(
      int id,
      ) async {
    final db = await database;

    return db.delete(
      'catatan',

      where: 'id = ?',

      whereArgs: [id],
    );
  }
}

// =====================================================
// HALAMAN DAFTAR CATATAN
// =====================================================

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() =>
      _CatatanPageState();
}

class _CatatanPageState
    extends State<CatatanPage> {
  late Future<List<Catatan>> _future;

  // Controller pencarian
  final TextEditingController _searchController =
  TextEditingController();

  // Urutan
  bool _terbaru = true;

  @override
  void initState() {
    super.initState();

    _future = DbHelper.semua();

    _muatPengaturan();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ===================================================
  // SHAREDPREFERENCES
  // ===================================================

  Future<void> _muatPengaturan() async {
    final prefs =
    await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _terbaru =
          prefs.getBool('urutan_terbaru') ?? true;
    });

    _muat();
  }

  Future<void> _simpanUrutan(
      bool terbaru,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'urutan_terbaru',
      terbaru,
    );
  }

  // ===================================================
  // MUAT DATA
  // ===================================================

  void _muat() {
    setState(() {
      _future = DbHelper.semua(
        kata: _searchController.text,
        terbaru: _terbaru,
      );
    });
  }

  // ===================================================
  // PENCARIAN
  // ===================================================

  void _cari(String kata) {
    _muat();
  }

  // ===================================================
  // GANTI URUTAN
  // ===================================================

  Future<void> _ubahUrutan(
      bool terbaru,
      ) async {
    setState(() {
      _terbaru = terbaru;
    });

    await _simpanUrutan(terbaru);

    _muat();
  }

  // ===================================================
  // BUKA FORM
  // ===================================================

  Future<void> _buka([
    Catatan? catatan,
  ]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormCatatanPage(
          catatan: catatan,
        ),
      ),
    );

    if (!mounted) return;

    _muat();
  }

  // ===================================================
  // LATIHAN 1: KONFIRMASI HAPUS
  // ===================================================

  Future<void> _hapus(
      Catatan catatan,
      ) async {
    final konfirmasi =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Hapus',
          ),

          content: const Text(
            'Hapus catatan ini?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Batal',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    await DbHelper.hapus(
      catatan.id!,
    );

    if (!mounted) return;

    _muat();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Catatan berhasil dihapus',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan Saya',
        ),

        actions: [
          // =========================================
          // PILIHAN URUTAN
          // =========================================

          PopupMenuButton<bool>(
            icon: const Icon(
              Icons.sort,
            ),

            onSelected: _ubahUrutan,

            itemBuilder: (context) {
              return [
                PopupMenuItem<bool>(
                  value: true,

                  child: Row(
                    children: [
                      if (_terbaru)
                        const Icon(
                          Icons.check,
                        ),

                      const SizedBox(
                        width: 8,
                      ),

                      const Text(
                        'Terbaru',
                      ),
                    ],
                  ),
                ),

                PopupMenuItem<bool>(
                  value: false,

                  child: Row(
                    children: [
                      if (!_terbaru)
                        const Icon(
                          Icons.check,
                        ),

                      const SizedBox(
                        width: 8,
                      ),

                      const Text(
                        'Terlama',
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ===========================================
          // SEARCH
          // ===========================================

          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              controller:
              _searchController,

              onChanged: _cari,

              decoration:
              InputDecoration(
                hintText:
                'Cari judul catatan...',

                prefixIcon:
                const Icon(
                  Icons.search,
                ),

                suffixIcon:
                _searchController
                    .text
                    .isNotEmpty
                    ? IconButton(
                  icon:
                  const Icon(
                    Icons.clear,
                  ),

                  onPressed: () {
                    _searchController
                        .clear();

                    _muat();
                  },
                )
                    : null,

                border:
                const OutlineInputBorder(),
              ),
            ),
          ),

          // ===========================================
          // LIST DATA
          // ===========================================

          Expanded(
            child:
            FutureBuilder<List<Catatan>>(
              future: _future,

              builder:
                  (context, snapshot) {
                if (snapshot
                    .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Galat: ${snapshot.error}',
                    ),
                  );
                }

                final data =
                    snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada catatan',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,

                  itemBuilder:
                      (context, i) {
                    final c = data[i];

                    return Card(
                      margin:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),

                      child: ListTile(
                        title: Text(
                          c.judul,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '${c.isi}\n'
                              'Dibuat: ${c.dibuat}',

                          maxLines: 3,

                          overflow:
                          TextOverflow
                              .ellipsis,
                        ),

                        isThreeLine: true,

                        onTap: () =>
                            _buka(c),

                        trailing:
                        IconButton(
                          icon:
                          const Icon(
                            Icons.delete,
                          ),

                          onPressed: () =>
                              _hapus(c),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ===============================================
      // TAMBAH
      // ===============================================

      floatingActionButton:
      FloatingActionButton(
        onPressed: () => _buka(),

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}

// =====================================================
// FORM CATATAN
// =====================================================

class FormCatatanPage
    extends StatefulWidget {
  final Catatan? catatan;

  const FormCatatanPage({
    super.key,
    this.catatan,
  });

  @override
  State<FormCatatanPage> createState() =>
      _FormCatatanPageState();
}

class _FormCatatanPageState
    extends State<FormCatatanPage> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _judul;

  late final TextEditingController
  _isi;

  @override
  void initState() {
    super.initState();

    _judul =
        TextEditingController(
          text:
          widget.catatan?.judul ?? '',
        );

    _isi =
        TextEditingController(
          text:
          widget.catatan?.isi ?? '',
        );
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();

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

    final baru =
        widget.catatan == null;

    final catatan = Catatan(
      id: widget.catatan?.id,

      judul: _judul.text.trim(),

      isi: _isi.text.trim(),

      // Tanggal dibuat hanya saat
      // catatan pertama kali dibuat.
      dibuat:
      widget.catatan?.dibuat ??
          _tanggalSekarang(),
    );

    if (baru) {
      await DbHelper.tambah(
        catatan,
      );
    } else {
      await DbHelper.ubah(
        catatan,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ===================================================
  // TANGGAL
  // ===================================================

  String _tanggalSekarang() {
    final now = DateTime.now();

    final tanggal = now.day
        .toString()
        .padLeft(2, '0');

    final bulan = now.month
        .toString()
        .padLeft(2, '0');

    final tahun =
    now.year.toString();

    final jam = now.hour
        .toString()
        .padLeft(2, '0');

    final menit = now.minute
        .toString()
        .padLeft(2, '0');

    return '$tanggal-$bulan-$tahun '
        '$jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    final baru =
        widget.catatan == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru
              ? 'Catatan Baru'
              : 'Ubah Catatan',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [
            // =========================================
            // JUDUL
            // =========================================

            TextFormField(
              controller: _judul,

              decoration:
              const InputDecoration(
                labelText: 'Judul',

                border:
                OutlineInputBorder(),
              ),

              validator: (v) {
                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 12,
            ),

            // =========================================
            // ISI
            // =========================================

            TextFormField(
              controller: _isi,

              maxLines: 6,

              decoration:
              const InputDecoration(
                labelText:
                'Isi catatan',

                border:
                OutlineInputBorder(),
              ),

              validator: (v) {
                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            // =========================================
            // SIMPAN
            // =========================================

            SizedBox(
              height: 50,

              child:
              ElevatedButton(
                onPressed: _simpan,

                child: Text(
                  baru
                      ? 'Simpan Catatan'
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