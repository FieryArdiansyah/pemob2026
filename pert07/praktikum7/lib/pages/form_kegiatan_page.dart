import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../models/kegiatan.dart';
import '../utils/format.dart';

class FormKegiatanPage
    extends StatefulWidget {
  const FormKegiatanPage({
    super.key,
  });

  @override
  State<FormKegiatanPage>
  createState() =>
      _FormKegiatanPageState();
}

class _FormKegiatanPageState
    extends State<FormKegiatanPage> {

  final _formKey =
  GlobalKey<FormState>();

  final _judulController =
  TextEditingController();

  final _nominalController =
  TextEditingController();

  DateTime tanggal =
  DateTime.now();

  Tipe tipe =
      Tipe.tanpa;

  String kategori =
      'Makan';

  Kegiatan? kegiatanEdit;

  bool sudahInit = false;

  final List<String> kategoriList = [
    'Makan',
    'Transport',
    'Belajar',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (sudahInit) return;

    final arg =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    if (arg is Kegiatan) {
      kegiatanEdit = arg;

      _judulController.text =
          arg.judul;

      _nominalController.text =
      arg.nominal == 0
          ? ''
          : arg.nominal
          .toString();

      tanggal =
          DateTime.parse(
            arg.tanggal,
          );

      tipe =
          arg.tipe;

      if (arg.kategori != '-') {
        kategori =
            arg.kategori;
      }
    }

    sudahInit = true;
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
      setState(() {
        tanggal = hasil;
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    int nominal = 0;

    if (tipe != Tipe.tanpa) {
      nominal =
          int.parse(
            _nominalController.text,
          );
    }

    final kegiatan =
    Kegiatan(
      id:
      kegiatanEdit?.id,

      judul:
      _judulController
          .text
          .trim(),

      tanggal:
      formatTanggalDatabase(
        tanggal,
      ),

      selesai:
      kegiatanEdit
          ?.selesai ??
          false,

      tipe:
      tipe,

      nominal:
      nominal,

      kategori:
      tipe ==
          Tipe.pengeluaran
          ? kategori
          : '-',
    );

    if (kegiatanEdit == null) {
      await DbHelper.tambah(
        kegiatan,
      );
    } else {
      await DbHelper.ubah(
        kegiatan,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _judulController.dispose();

    _nominalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kegiatanEdit == null
              ? 'Tambah Kegiatan'
              : 'Ubah Kegiatan',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [
            TextFormField(
              controller:
              _judulController,

              decoration:
              const InputDecoration(
                labelText:
                'Nama kegiatan',
                border:
                OutlineInputBorder(),
              ),

              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Nama kegiatan wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            ListTile(
              contentPadding:
              EdgeInsets.zero,

              title:
              const Text(
                'Tanggal',
              ),

              subtitle:
              Text(
                formatTanggalDatabase(
                  tanggal,
                ),
              ),

              trailing:
              const Icon(
                Icons.calendar_month,
              ),

              onTap:
              _pilihTanggal,
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<Tipe>(
              value: tipe,

              decoration:
              const InputDecoration(
                labelText:
                'Jenis keuangan',
                border:
                OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value:
                  Tipe.tanpa,
                  child:
                  Text(
                    'Tidak melibatkan uang',
                  ),
                ),

                DropdownMenuItem(
                  value:
                  Tipe.pemasukan,
                  child:
                  Text(
                    'Pemasukan',
                  ),
                ),

                DropdownMenuItem(
                  value:
                  Tipe.pengeluaran,
                  child:
                  Text(
                    'Pengeluaran',
                  ),
                ),
              ],

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  tipe = value;

                  if (tipe ==
                      Tipe.tanpa) {
                    _nominalController
                        .clear();
                  }
                });
              },
            ),

            if (tipe != Tipe.tanpa)
              Padding(
                padding:
                const EdgeInsets.only(
                  top: 16,
                ),
                child:
                TextFormField(
                  controller:
                  _nominalController,

                  keyboardType:
                  TextInputType
                      .number,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Nominal',
                    prefixText:
                    'Rp ',
                    border:
                    OutlineInputBorder(),
                  ),

                  validator:
                      (value) {
                    if (tipe ==
                        Tipe.tanpa) {
                      return null;
                    }

                    final nominal =
                    int.tryParse(
                      value ?? '',
                    );

                    if (nominal ==
                        null ||
                        nominal <=
                            0) {
                      return 'Nominal harus lebih dari 0';
                    }

                    return null;
                  },
                ),
              ),

            if (tipe ==
                Tipe.pengeluaran)
              Padding(
                padding:
                const EdgeInsets.only(
                  top: 16,
                ),

                child:
                DropdownButtonFormField<
                    String>(
                  value:
                  kategori,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Kategori',
                    border:
                    OutlineInputBorder(),
                  ),

                  items:
                  kategoriList
                      .map(
                        (
                        item,
                        ) =>
                        DropdownMenuItem(
                          value:
                          item,
                          child:
                          Text(
                            item,
                          ),
                        ),
                  )
                      .toList(),

                  onChanged:
                      (value) {
                    if (value !=
                        null) {
                      setState(() {
                        kategori =
                            value;
                      });
                    }
                  },
                ),
              ),

            const SizedBox(
              height: 30,
            ),

            FilledButton.icon(
              onPressed:
              _simpan,

              icon:
              const Icon(
                Icons.save,
              ),

              label:
              const Text(
                'Simpan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}