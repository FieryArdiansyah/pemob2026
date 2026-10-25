import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'kategori': kategori,
      'tanggal': tanggal,
    };
  }

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
              'tanggal TEXT NOT NULL'
              ')',
        );
      },
    );

    return _db!;
  }

  // ===================================================
  // TAMBAH
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
  // TAMPILKAN
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
  // EDIT
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
  // HAPUS
  // ===================================================

  static Future<int> hapus(
      int id,
      ) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// =====================================================
// MY APP
// =====================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PengeluaranPage(),
    );
  }
}

// =====================================================
// HALAMAN UTAMA
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

  // SharedPreferences
  bool _gelap = false;

  @override
  void initState() {
    super.initState();

    _future = DbHelper.semua();

    _muatPengaturan();
  }

  // ===================================================
  // LOAD SHAREDPREFERENCES
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

  // ===================================================
  // SIMPAN MODE GELAP
  // ===================================================

  Future<void> _ubahTema(
      bool nilai,
      ) async {
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
  // MUAT ULANG DATA
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
  // HAPUS
  // ===================================================

  Future<void> _hapus(
      Pengeluaran pengeluaran,
      ) async {
    final konfirmasi =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Hapus',
          ),
          content: Text(
            'Hapus pengeluaran "${pengeluaran.nama}"?',
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
      pengeluaran.id!,
    );

    if (!mounted) return;

    _muat();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Data berhasil dihapus',
        ),
      ),
    );
  }

  // ===================================================
  // FORMAT RUPIAH
  // ===================================================

  String _rupiah(int angka) {
    final text = angka.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return 'Rp ${buffer.toString()}';
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
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'tema') {
                  _ubahTema(!_gelap);
                }
              },

              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'tema',
                    child: Row(
                      children: [
                        Icon(
                          _gelap
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          _gelap
                              ? 'Mode terang'
                              : 'Mode gelap',
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),

        body: FutureBuilder<List<Pengeluaran>>(
          future: _future,

          builder: (context, snapshot) {
            // =========================================
            // LOADING
            // =========================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                CircularProgressIndicator(),
              );
            }

            // =========================================
            // ERROR
            // =========================================

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan:\n'
                      '${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              );
            }

            final data =
                snapshot.data ?? [];

            // =========================================
            // TOTAL
            // =========================================

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
                  margin:
                  const EdgeInsets.all(16),

                  child: Padding(
                    padding:
                    const EdgeInsets.all(20),

                    child: Column(
                      children: [
                        const Text(
                          'Total Pengeluaran',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          _rupiah(total),
                          style:
                          const TextStyle(
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
                // LIST DATA
                // =======================================

                else
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                      data.length,

                      itemBuilder:
                          (context, index) {
                        final item =
                        data[index];

                        return Card(
                          margin:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),

                          child: ListTile(
                            leading:
                            CircleAvatar(
                              child: Text(
                                item.nama[0]
                                    .toUpperCase(),
                              ),
                            ),

                            title: Text(
                              item.nama,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              '${item.kategori}\n'
                                  '${item.tanggal}',
                            ),

                            isThreeLine:
                            true,

                            trailing: Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                              children: [
                                Text(
                                  _rupiah(
                                    item.jumlah,
                                  ),
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                      const Icon(
                                        Icons.edit,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _bukaForm(
                                            item,
                                          ),
                                    ),

                                    IconButton(
                                      icon:
                                      const Icon(
                                        Icons.delete,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _hapus(
                                            item,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
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

        // =============================================
        // TAMBAH
        // =============================================

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

  late final TextEditingController
  _namaController;

  late final TextEditingController
  _jumlahController;

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

    _namaController =
        TextEditingController(
          text:
          widget.pengeluaran?.nama ??
              '',
        );

    _jumlahController =
        TextEditingController(
          text:
          widget.pengeluaran?.jumlah
              .toString() ??
              '',
        );

    _kategori =
        widget.pengeluaran?.kategori;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();

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
    int.parse(
      _jumlahController.text.trim(),
    );

    final pengeluaran =
    Pengeluaran(
      id: widget.pengeluaran?.id,

      nama:
      _namaController.text.trim(),

      jumlah: jumlah,

      kategori: _kategori!,

      tanggal:
      widget.pengeluaran?.tanggal ??
          _tanggalSekarang(),
    );

    // ===============================================
    // TAMBAH
    // ===============================================

    if (widget.pengeluaran == null) {
      await DbHelper.tambah(
        pengeluaran,
      );
    }

    // ===============================================
    // EDIT
    // ===============================================

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
              controller:
              _namaController,

              decoration:
              const InputDecoration(
                labelText:
                'Nama pengeluaran',

                hintText:
                'Contoh: Makan siang',

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

            const SizedBox(
              height: 16,
            ),

            // =========================================
            // JUMLAH
            // =========================================

            TextFormField(
              controller:
              _jumlahController,

              keyboardType:
              TextInputType.number,

              decoration:
              const InputDecoration(
                labelText:
                'Jumlah',

                hintText:
                'Contoh: 25000',

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

            const SizedBox(
              height: 16,
            ),

            // =========================================
            // KATEGORI
            // =========================================

            DropdownButtonFormField<String>(
              initialValue: _kategori,

              decoration:
              const InputDecoration(
                labelText:
                'Kategori',

                border:
                OutlineInputBorder(),
              ),

              items: _kategoriList
                  .map(
                    (kategori) {
                  return DropdownMenuItem<
                      String>(
                    value: kategori,

                    child:
                    Text(kategori),
                  );
                },
              )
                  .toList(),

              onChanged: (value) {
                setState(() {
                  _kategori =
                      value;
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

            const SizedBox(
              height: 24,
            ),

            // =========================================
            // TOMBOL SIMPAN
            // =========================================

            SizedBox(
              height: 50,

              child:
              ElevatedButton.icon(
                onPressed: _simpan,

                icon: const Icon(
                  Icons.save,
                ),

                label: Text(
                  baru
                      ? 'Simpan'
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