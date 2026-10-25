import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tabungku/services/health_service.dart';

void main() {
  group('cekServer', () {
    test('membaca status dan waktu saat sehat', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/health');

        return http.Response(
          '{"status":"ok",'
          '"waktu_server":"2026-10-25T08:00:00",'
          '"database":"ok",'
          '"mysql_version":"8.4.0"}',
          200,
        );
      });

      final hasil = await cekServer(client: client);

      expect(hasil.status, 'ok');
      expect(hasil.waktuServer, '2026-10-25T08:00:00');
      expect(hasil.apiTerhubung, isTrue);
      expect(hasil.databaseTerhubung, isTrue);
      expect(hasil.mysqlVersion, '8.4.0');

      client.close();
    });

    test('HTTP 503 berarti API hidup tetapi database mati', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"status":"error",'
          '"waktu_server":"2026-10-25T08:00:00",'
          '"database":"error",'
          '"mysql_version":null,'
          '"pesan":"Database tidak tersedia"}',
          503,
        );
      });

      final hasil = await cekServer(client: client);

      expect(hasil.kodeHttp, 503);
      expect(hasil.apiTerhubung, isTrue);
      expect(hasil.databaseTerhubung, isFalse);
      expect(hasil.pesan, contains('Database tidak tersedia'));

      client.close();
    });

    test('HTTP 500 ditangani sebagai error', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"detail":"Internal Server Error"}',
          500,
        );
      });

      await expectLater(
        cekServer(client: client),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'pesan error',
            contains('500'),
          ),
        ),
      );

      client.close();
    });
  });
}
