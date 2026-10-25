import 'package:flutter/material.dart';

import '../state/pengaturan.dart';
import '../utils/format.dart';

class PengaturanPage
    extends StatefulWidget {

  const PengaturanPage({
    super.key,
  });

  @override
  State<PengaturanPage>
  createState() =>
      _PengaturanPageState();
}

class _PengaturanPageState
    extends State<PengaturanPage> {

  final pilihanWarna = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();

    pengaturan.addListener(
      _refresh,
    );
  }

  @override
  void dispose() {
    pengaturan.removeListener(
      _refresh,
    );

    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
      const EdgeInsets.all(16),

      children: [
        SwitchListTile(
          title:
          const Text(
            'Mode Gelap',
          ),

          value:
          pengaturan.gelap,

          onChanged: (value) {
            pengaturan.setGelap(
              value,
            );
          },
        ),

        const Divider(),

        const Text(
          'Target Tabungan Harian',
          style:
          TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          formatRupiah(
            pengaturan.target,
          ),
          style:
          const TextStyle(
            fontSize: 24,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        Slider(
          min: 5000,
          max: 100000,
          divisions: 19,

          value:
          pengaturan.target
              .toDouble(),

          label:
          formatRupiah(
            pengaturan.target,
          ),

          onChanged: (value) {
            pengaturan.setTarget(
              value.toInt(),
            );
          },
        ),

        const Divider(),

        const Text(
          'Warna Tema',
          style:
          TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 15,
        ),

        Wrap(
          spacing: 12,
          children:
          pilihanWarna.map(
                (warna) {
              final aktif =
                  warna.toARGB32() ==
                      pengaturan.warna;

              return InkWell(
                onTap: () {
                  pengaturan
                      .setWarna(
                    warna,
                  );
                },

                child:
                CircleAvatar(
                  backgroundColor:
                  warna,

                  child:
                  aktif
                      ? const Icon(
                    Icons.check,
                    color:
                    Colors.white,
                  )
                      : null,
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}