import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final ValueChanged<bool?> onCheck;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onCheck,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color warnaNominal = Colors.grey;

    String nominal = '';

    if (kegiatan.tipe == Tipe.pemasukan) {
      warnaNominal = Colors.green;

      nominal =
      '+${formatRupiah(kegiatan.nominal)}';
    }

    if (kegiatan.tipe == Tipe.pengeluaran) {
      warnaNominal = Colors.red;

      nominal =
      '-${formatRupiah(kegiatan.nominal)}';
    }

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: kegiatan.selesai,
          onChanged: onCheck,
        ),

        title: Text(
          kegiatan.judul,
          style: TextStyle(
            decoration:
            kegiatan.selesai
                ? TextDecoration.lineThrough
                : null,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nominal.isNotEmpty)
              Text(
                nominal,
                style: TextStyle(
                  color: warnaNominal,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (kegiatan.tipe ==
                Tipe.pengeluaran)
              Text(kegiatan.kategori),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            }

            if (value == 'hapus') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Ubah'),
            ),
            const PopupMenuItem(
              value: 'hapus',
              child: Text('Hapus'),
            ),
          ],
        ),
      ),
    );
  }
}