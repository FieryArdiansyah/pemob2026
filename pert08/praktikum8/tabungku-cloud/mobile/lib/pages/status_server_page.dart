import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/health_service.dart';

class StatusServerPage extends StatefulWidget {
  const StatusServerPage({super.key});

  @override
  State<StatusServerPage> createState() =>
      _StatusServerPageState();
}

class _StatusServerPageState extends State<StatusServerPage> {
  late Future<StatusServer> _future;

  @override
  void initState() {
    super.initState();
    _future = cekServer();
  }

  void _periksaLagi() {
    setState(() {
      _future = cekServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<StatusServer>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _JaringanGagal(
                error: snapshot.error.toString(),
                onPeriksaLagi: _periksaLagi,
              );
            }

            if (!snapshot.hasData) {
              return _JaringanGagal(
                error: 'Tidak ada respons dari server.',
                onPeriksaLagi: _periksaLagi,
              );
            }

            return _StatusHasil(
              server: snapshot.data!,
              onPeriksaLagi: _periksaLagi,
            );
          },
        ),
      ),
    );
  }
}

class _StatusHasil extends StatelessWidget {
  final StatusServer server;
  final VoidCallback onPeriksaLagi;

  const _StatusHasil({
    required this.server,
    required this.onPeriksaLagi,
  });

  @override
  Widget build(BuildContext context) {
    final apiOk = server.apiTerhubung;
    final databaseOk = server.databaseTerhubung;

    final judul = !apiOk
        ? 'Server tidak terhubung'
        : databaseOk
            ? 'API dan database terhubung'
            : 'API hidup, database bermasalah';

    final warnaJudul = !apiOk
        ? Colors.red
        : databaseOk
            ? Colors.green
            : Colors.orange;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            !apiOk
                ? Icons.cloud_off
                : databaseOk
                    ? Icons.check_circle
                    : Icons.cloud_done,
            size: 80,
            color: warnaJudul,
          ),
          const SizedBox(height: 12),
          Text(
            judul,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: warnaJudul,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    apiOk ? Icons.check_circle : Icons.cancel,
                    color: apiOk ? Colors.green : Colors.red,
                  ),
                  title: const Text('Status API'),
                  subtitle: Text(
                    apiOk
                        ? 'Terhubung (HTTP ${server.kodeHttp})'
                        : 'Tidak terhubung',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    databaseOk
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: databaseOk
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: const Text('Status Database MySQL'),
                  subtitle: Text(
                    databaseOk
                        ? 'Terhubung'
                        : 'Tidak terhubung',
                  ),
                ),
                if (server.mysqlVersion != null)
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Versi MySQL'),
                    subtitle: Text(server.mysqlVersion!),
                  ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Waktu server'),
                  subtitle: Text(server.waktuServer),
                ),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text('Latensi'),
                  subtitle: Text(
                    '${server.latensi.inMilliseconds} ms',
                  ),
                ),
                if (server.pesan != null &&
                    server.pesan!.isNotEmpty)
                  ListTile(
                    leading: const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                    ),
                    title: const Text('Detail masalah'),
                    subtitle: SelectableText(server.pesan!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onPeriksaLagi,
            icon: const Icon(Icons.refresh),
            label: const Text('Periksa lagi'),
          ),
        ],
      ),
    );
  }
}

class _JaringanGagal extends StatelessWidget {
  final String error;
  final VoidCallback onPeriksaLagi;

  const _JaringanGagal({
    required this.error,
    required this.onPeriksaLagi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Server tidak terhubung',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Alamat API: $apiUrl'),
            const SizedBox(height: 8),
            SelectableText(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onPeriksaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Periksa lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
