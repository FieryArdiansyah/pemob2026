
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../state/pengaturan.dart';
import '../utils/format.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({
    super.key,
  });

  @override
  State<PengaturanPage> createState() =>
      _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
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

    pengaturan.addListener(_refresh);
  }

  @override
  void dispose() {
    pengaturan.removeListener(_refresh);

    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  // Membuka dialog untuk mengubah alamat API.
  Future<void> _ubahAlamatApi() async {
    final urlBaru = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _DialogAlamatApi(
          alamatAwal: apiUrl,
        );
      },
    );

    if (urlBaru == null || !mounted) {
      return;
    }

    try {
      await ApiConfig.setApiUrl(urlBaru);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alamat API berhasil disimpan',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan alamat API: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pengaturan mode gelap.
        SwitchListTile(
          title: const Text('Mode Gelap'),
          value: pengaturan.gelap,
          onChanged: (value) {
            pengaturan.setGelap(value);
          },
        ),

        const Divider(),

        // Target tabungan harian.
        const Text(
          'Target Tabungan Harian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          formatRupiah(pengaturan.target),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        Slider(
          min: 5000,
          max: 100000,
          divisions: 19,
          value: pengaturan.target.toDouble(),
          label: formatRupiah(pengaturan.target),
          onChanged: (value) {
            pengaturan.setTarget(value.toInt());
          },
        ),

        const Divider(),

        // Pemilihan warna tema.
        const Text(
          'Warna Tema',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: pilihanWarna.map((warna) {
            final aktif =
                warna.toARGB32() == pengaturan.warna;

            return InkWell(
              onTap: () {
                pengaturan.setWarna(warna);
              },
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                backgroundColor: warna,
                child: aktif
                    ? const Icon(
                  Icons.check,
                  color: Colors.white,
                )
                    : null,
              ),
            );
          }).toList(),
        ),

        const Divider(),

        // Pengaturan alamat API.
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('Alamat API'),
          subtitle: Text(apiUrl),
          trailing: const Icon(Icons.edit),
          onTap: _ubahAlamatApi,
        ),
      ],
    );
  }
}

// Dialog terpisah agar controller dikelola dengan benar.
class _DialogAlamatApi extends StatefulWidget {
  final String alamatAwal;

  const _DialogAlamatApi({
    required this.alamatAwal,
  });

  @override
  State<_DialogAlamatApi> createState() =>
      _DialogAlamatApiState();
}

class _DialogAlamatApiState
    extends State<_DialogAlamatApi> {
  late final TextEditingController _controller;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.alamatAwal,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah alamat API'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.url,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Alamat API',
            hintText: 'http://10.0.2.2:8000',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final input = (value ?? '').trim();
            final uri = Uri.tryParse(input);

            if (uri == null ||
                !uri.hasAuthority ||
                uri.host.isEmpty ||
                (uri.scheme != 'http' &&
                    uri.scheme != 'https')) {
              return 'Masukkan URL HTTP atau HTTPS yang valid';
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final alamat = _controller.text.trim();

              Navigator.of(context).pop(alamat);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
