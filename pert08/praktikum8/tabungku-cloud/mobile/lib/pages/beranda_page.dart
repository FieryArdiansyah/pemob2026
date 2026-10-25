import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';
import '../widgets/kegiatan_tile.dart';
import '../widgets/ringkasan_card.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({
    super.key,
  });

  @override
  State<BerandaPage> createState() =>
      _BerandaPageState();
}

class _BerandaPageState
    extends State<BerandaPage> {

  late Future<void> _future;

  List<Kegiatan> daftar = [];

  Ringkasan? ringkasan;

  @override
  void initState() {
    super.initState();

    _future = _ambilData();

    versiData.addListener(_muatUlang);

    pengaturan.addListener(_muatUlang);
  }

  @override
  void dispose() {
    versiData.removeListener(_muatUlang);

    pengaturan.removeListener(_muatUlang);

    super.dispose();
  }

  void _muatUlang() {
    if (!mounted) return;

    setState(() {
      _future = _ambilData();
    });
  }

  Future<void> _ambilData() async {
    final tanggal =
    formatTanggalDatabase(
      DateTime.now(),
    );

    daftar =
    await DbHelper.pada(
      tanggal,
    );

    ringkasan =
    await DbHelper.ringkasan(
      tanggal,
    );
  }

  Future<void> _hapus(
      Kegiatan kegiatan,
      ) async {
    final konfirmasi =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus kegiatan?',
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${kegiatan.judul}"?',
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
            FilledButton(
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

    if (konfirmasi == true &&
        kegiatan.id != null) {
      await DbHelper.hapus(
        kegiatan.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _future,
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
              ),
            );
          }

          final dataRingkasan =
              ringkasan ??
                  Ringkasan(
                    jumlahKegiatan: 0,
                    selesai: 0,
                    pemasukan: 0,
                    pengeluaran: 0,
                  );

          return ListView(
            padding:
            const EdgeInsets.all(16),
            children: [
              RingkasanCard(
                ringkasan:
                dataRingkasan,
                target:
                pengaturan.target,
              ),

              const SizedBox(height: 16),

              const Text(
                'Kegiatan Hari Ini',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              if (daftar.isEmpty)
                const Padding(
                  padding:
                  EdgeInsets.symmetric(
                    vertical: 40,
                  ),
                  child: Center(
                    child: Text(
                      'Belum ada kegiatan hari ini.',
                    ),
                  ),
                ),

              for (final kegiatan
              in daftar)
                KegiatanTile(
                  kegiatan: kegiatan,

                  onCheck: (
                      value,
                      ) async {
                    await DbHelper.ubah(
                      kegiatan.copyWith(
                        selesai:
                        value ??
                            false,
                      ),
                    );
                  },

                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      '/form',
                      arguments:
                      kegiatan,
                    );
                  },

                  onDelete: () {
                    _hapus(kegiatan);
                  },
                ),
            ],
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/form',
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}