import 'package:flutter/material.dart';
import 'pages/status_server_page.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/form_kegiatan_page.dart';
import 'pages/shell_page.dart';
import 'state/pengaturan.dart';
import 'config/api_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized();

  await initializeDateFormatting(
    'id_ID',
    null,
  );

  await pengaturan.muat();

  await ApiConfig.load();

  runApp(
    const TabungKuApp(),
  );
}

class TabungKuApp
    extends StatefulWidget {

  const TabungKuApp({
    super.key,
  });

  @override
  State<TabungKuApp>
  createState() =>
      _TabungKuAppState();
}

class _TabungKuAppState
    extends State<TabungKuApp> {

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final warna =
    Color(
      pengaturan.warna,
    );

    return MaterialApp(
      debugShowCheckedModeBanner:
      false,

      title:
      'TabungKu',

      theme:
      ThemeData(
        useMaterial3:
        true,

        colorScheme:
        ColorScheme.fromSeed(
          seedColor:
          warna,

          brightness:
          Brightness.light,
        ),
      ),

      darkTheme:
      ThemeData(
        useMaterial3:
        true,

        colorScheme:
        ColorScheme.fromSeed(
          seedColor:
          warna,

          brightness:
          Brightness.dark,
        ),
      ),

      themeMode:
      pengaturan.gelap
          ? ThemeMode.dark
          : ThemeMode.light,

      initialRoute:
      '/',


      routes: {
        '/': (context) =>
        const ShellPage(),

        '/form': (context) =>
        const FormKegiatanPage(),

        '/status': (context) =>
        const StatusServerPage(),
      },

    );
  }
}