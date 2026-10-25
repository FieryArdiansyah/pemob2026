import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class LaporanPage
    extends StatefulWidget {
  const LaporanPage({
    super.key,
  });

  @override
  State<LaporanPage>
  createState() =>
      _LaporanPageState();
}

class _LaporanPageState
    extends State<LaporanPage> {

  DateTime tanggal =
  DateTime.now();

  Ringkasan? ringkasan;

  Map<String, int> kategori = {};

  List<Map<String, Object?>>
  tujuhHari = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    versiData.addListener(
      _muat,
    );

    _muat();
  }

  @override
  void dispose() {
    versiData.removeListener(
      _muat,
    );

    super.dispose();
  }

  Future<void> _muat() async {
    final tanggalDb =
    formatTanggalDatabase(
      tanggal,
    );

    final hasilRingkasan =
    await DbHelper.ringkasan(
      tanggalDb,
    );

    final hasilKategori =
    await DbHelper
        .pengeluaranPerKategori(
      tanggalDb,
    );

    final hasil7Hari =
    await DbHelper
        .tujuhHariTerakhir();

    if (!mounted) return;

    setState(() {
      ringkasan =
          hasilRingkasan;

      kategori =
          hasilKategori;

      tujuhHari =
          hasil7Hari;

      loading =
      false;
    });
  }

  Future<void>
  _pilihTanggal() async {

    final hasil =
    await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate:
      DateTime(2020),
      lastDate:
      DateTime(2100),
    );

    if (hasil != null) {
      tanggal = hasil;

      setState(() {
        loading = true;
      });

      await _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    final data =
    ringkasan!;

    return ListView(
      padding:
      const EdgeInsets.all(16),

      children: [
        OutlinedButton.icon(
          onPressed:
          _pilihTanggal,

          icon:
          const Icon(
            Icons.calendar_month,
          ),

          label:
          Text(
            formatTanggalDatabase(
              tanggal,
            ),
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        const Text(
          'Ringkasan',
          style:
          TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          'Kegiatan: '
              '${data.selesai}/${data.jumlahKegiatan}',
        ),

        Text(
          'Pemasukan: ${formatRupiah(data.pemasukan)}',
        ),

        Text(
          'Pengeluaran: ${formatRupiah(data.pengeluaran)}',
        ),

        Text(
          'Tabungan: ${formatRupiah(data.tabungan)}',
        ),

        const Divider(
          height: 40,
        ),

        const Text(
          'Pengeluaran per Kategori',
          style:
          TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        if (kategori.isEmpty)
          const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 20,
            ),
            child:
            Text(
              'Tidak ada pengeluaran.',
            ),
          ),

        ...kategori.entries.map(
              (item) =>
              ListTile(
                title:
                Text(
                  item.key,
                ),

                trailing:
                Text(
                  formatRupiah(
                    item.value,
                  ),
                ),
              ),
        ),

        const Divider(
          height: 40,
        ),

        const Text(
          '7 Hari Terakhir',
          style:
          TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        for (final row
        in tujuhHari)
          Card(
            child:
            ListTile(
              title:
              Text(
                row['tanggal']
                    .toString(),
              ),

              subtitle:
              Text(
                'Masuk: ${formatRupiah((row['masuk'] as num).toInt())}\n'
                    'Keluar: ${formatRupiah((row['keluar'] as num).toInt())}',
              ),
            ),
          ),
      ],
    );
  }
}