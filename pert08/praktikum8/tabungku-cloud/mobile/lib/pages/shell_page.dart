import 'package:flutter/material.dart';

import 'beranda_page.dart';
import 'laporan_page.dart';
import 'pengaturan_page.dart';

class ShellPage
    extends StatefulWidget {

  const ShellPage({
    super.key,
  });

  @override
  State<ShellPage>
  createState() =>
      _ShellPageState();
}

class _ShellPageState
    extends State<ShellPage> {

  int index = 0;

  final halaman = const [
    BerandaPage(),
    LaporanPage(),
    PengaturanPage(),
  ];

  final judul = const [
    'Hari Ini',
    'Laporan',
    'Pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        title:
        Text(
          judul[index],
        ),
      ),

      body:
      IndexedStack(
        index:
        index,
        children:
        halaman,
      ),

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        index,

        onDestinationSelected:
            (value) {
          setState(() {
            index =
                value;
          });
        },

        destinations:
        const [
          NavigationDestination(
            icon:
            Icon(
              Icons.today,
            ),
            label:
            'Hari Ini',
          ),

          NavigationDestination(
            icon:
            Icon(
              Icons.bar_chart,
            ),
            label:
            'Laporan',
          ),

          NavigationDestination(
            icon:
            Icon(
              Icons.settings,
            ),
            label:
            'Pengaturan',
          ),
        ],
      ),
    );
  }
}