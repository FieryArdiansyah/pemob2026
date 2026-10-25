import 'package:flutter/material.dart';

import '../models/kegiatan.dart';
import '../utils/format.dart';

class RingkasanCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final int target;

  const RingkasanCard({
    super.key,
    required this.ringkasan,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final tabungan = ringkasan.tabungan;

    double progress;

    if (target <= 0) {
      progress = 0;
    } else {
      progress = tabungan / target;
    }

    progress = progress.clamp(
      0.0,
      1.0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Kegiatan: '
                  '${ringkasan.selesai}/${ringkasan.jumlahKegiatan}',
            ),

            Text(
              'Pemasukan: ${formatRupiah(ringkasan.pemasukan)}',
            ),

            Text(
              'Pengeluaran: ${formatRupiah(ringkasan.pengeluaran)}',
            ),

            const Divider(),

            Text(
              'Tabungan: ${formatRupiah(tabungan)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                tabungan < 0
                    ? Colors.red
                    : Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: progress,
              ),
              duration: const Duration(
                milliseconds: 700,
              ),
              builder: (
                  context,
                  value,
                  child,
                  ) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                );
              },
            ),

            const SizedBox(height: 8),

            Text(
              'Target: ${formatRupiah(target)}',
            ),

            if (tabungan < 0)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  '⚠ Pengeluaran lebih besar dari pemasukan.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),

            if (tabungan >= target)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  '🎉 Target tabungan tercapai!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}