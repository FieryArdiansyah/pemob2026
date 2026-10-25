import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/kegiatan.dart';

final ValueNotifier<int> versiData = ValueNotifier<int>(0);

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final pathDatabase = await getDatabasesPath();

    final path = join(
      pathDatabase,
      'tabungku.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL,
            tipe TEXT NOT NULL,
            nominal INTEGER NOT NULL,
            kategori TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<int> tambah(Kegiatan kegiatan) async {
    final db = await database;

    final map = kegiatan.toMap();

    map.remove('id');

    final id = await db.insert(
      'kegiatan',
      map,
    );

    versiData.value++;

    return id;
  }

  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await database;

    final hasil = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'id DESC',
    );

    return hasil
        .map(
          (row) => Kegiatan.fromMap(row),
    )
        .toList();
  }

  static Future<int> ubah(Kegiatan kegiatan) async {
    final db = await database;

    final hasil = await db.update(
      'kegiatan',
      kegiatan.toMap(),
      where: 'id = ?',
      whereArgs: [kegiatan.id],
    );

    versiData.value++;

    return hasil;
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    final hasil = await db.delete(
      'kegiatan',
      where: 'id = ?',
      whereArgs: [id],
    );

    versiData.value++;

    return hasil;
  }

  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await database;

    final hasil = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS jumlah,
        COALESCE(SUM(selesai), 0) AS selesai,

        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pemasukan'
              THEN nominal
            END
          ),
          0
        ) AS masuk,

        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pengeluaran'
              THEN nominal
            END
          ),
          0
        ) AS keluar

      FROM kegiatan

      WHERE tanggal = ?
      ''',
      [tanggal],
    );

    final baris = hasil.first;

    return Ringkasan(
      jumlahKegiatan: (baris['jumlah'] as num).toInt(),
      selesai: (baris['selesai'] as num).toInt(),
      pemasukan: (baris['masuk'] as num).toInt(),
      pengeluaran: (baris['keluar'] as num).toInt(),
    );
  }

  static Future<Map<String, int>> pengeluaranPerKategori(
      String tanggal,
      ) async {
    final db = await database;

    final hasil = await db.rawQuery(
      '''
      SELECT kategori,
             COALESCE(SUM(nominal), 0) AS total
      FROM kegiatan
      WHERE tanggal = ?
        AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
      ''',
      [tanggal],
    );

    final Map<String, int> data = {};

    for (final row in hasil) {
      data[row['kategori'] as String] =
          (row['total'] as num).toInt();
    }

    return data;
  }

  static Future<List<Map<String, Object?>>> tujuhHariTerakhir() async {
    final db = await database;

    return db.rawQuery(
      '''
      SELECT
        tanggal,
        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pemasukan'
              THEN nominal
            END
          ),
          0
        ) AS masuk,

        COALESCE(
          SUM(
            CASE
              WHEN tipe = 'pengeluaran'
              THEN nominal
            END
          ),
          0
        ) AS keluar

      FROM kegiatan

      WHERE tanggal >= date('now', '-6 day')

      GROUP BY tanggal
      ORDER BY tanggal DESC
      ''',
    );
  }
}