import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class StatusServer {
  final String status;
  final String waktuServer;
  final String database;
  final String? mysqlVersion;
  final String? pesan;
  final int kodeHttp;
  final Duration latensi;

  const StatusServer({
    required this.status,
    required this.waktuServer,
    required this.database,
    required this.mysqlVersion,
    required this.pesan,
    required this.kodeHttp,
    required this.latensi,
  });

  bool get apiTerhubung =>
      kodeHttp == 200 || kodeHttp == 503;

  bool get databaseTerhubung =>
      kodeHttp == 200 && database == 'ok';
}

Future<StatusServer> cekServer({http.Client? client}) async {
  final c = client ?? http.Client();
  final jam = Stopwatch()..start();

  try {
    final res = await c
        .get(Uri.parse('$apiUrl/health'))
        .timeout(batasWaktu);

    jam.stop();

    if (res.statusCode != 200 && res.statusCode != 503) {
      throw Exception(
        'Server membalas kode ${res.statusCode}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    return StatusServer(
      status: data['status'] as String? ?? 'error',
      waktuServer: data['waktu_server'] as String? ?? '-',
      database: data['database'] as String? ?? 'error',
      mysqlVersion: data['mysql_version'] as String?,
      pesan: data['pesan'] as String?,
      kodeHttp: res.statusCode,
      latensi: jam.elapsed,
    );
  } finally {
    if (client == null) {
      c.close();
    }
  }
}
