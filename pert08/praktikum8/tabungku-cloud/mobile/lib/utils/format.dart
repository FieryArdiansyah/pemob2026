import 'package:intl/intl.dart';

String formatTanggalDatabase(DateTime tanggal) {
  return DateFormat('yyyy-MM-dd').format(tanggal);
}

String formatTanggalIndonesia(DateTime tanggal) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal);
}

String formatRupiah(int nominal) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  return formatter.format(nominal);
}