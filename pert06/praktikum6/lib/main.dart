import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<int>(0);

const pilihanWarna = <Color>[
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

const daftarItem = <Item>[
  Item('Pantai', Icons.beach_access, 'Wisata pantai yang indah.'),
  Item('Gunung', Icons.landscape, 'Pemandangan alam pegunungan.'),
  Item('Kota', Icons.location_city, 'Jelajahi suasana perkotaan.'),
  Item('Taman', Icons.park, 'Tempat santai bersama keluarga.'),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  themeMode.value = prefs.getBool('modeGelap') == true
      ? ThemeMode.dark
      : ThemeMode.light;

  seedColor.value = prefs.getInt('warnaTema') ?? 0;

  if (seedColor.value < 0 ||
      seedColor.value >= pilihanWarna.length) {
    seedColor.value = 0;
  }

  runApp(const MyApp());
}

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Galeri Wisata',
          debugShowCheckedModeBanner: false,
          theme: buatTema(
            pilihanWarna[seedColor.value],
            Brightness.light,
          ),
          darkTheme: buatTema(
            pilihanWarna[seedColor.value],
            Brightness.dark,
          ),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (_) => const ShellPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final arg = settings.arguments;

              if (arg is! Item) return null;

              return PageRouteBuilder<void>(
                settings: settings,
                pageBuilder: (_, animation, secondaryAnimation) {
                  return DetailPage(item: arg);
                },
                transitionsBuilder:
                    (_, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration:
                const Duration(milliseconds: 400),
              );
            }

            return null;
          },
          onUnknownRoute: (_) {
            return MaterialPageRoute<void>(
              builder: (_) => const NotFoundPage(),
            );
          },
        );
      },
    );
  }
}

class Item {
  final String nama;
  final IconData ikon;
  final String deskripsi;

  const Item(this.nama, this.ikon, this.deskripsi);
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _judul = [
    'Beranda',
    'Katalog Wisata',
    'Pengaturan',
  ];

  void _pindahTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_judul[_index]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                ),
                child: Text(
                  'Galeri Wisata',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Beranda'),
                onTap: () {
                  Navigator.pop(context);
                  _pindahTab(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Katalog Wisata'),
                onTap: () {
                  Navigator.pop(context);
                  _pindahTab(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  _pindahTab(2);
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          BerandaTab(),
          KatalogTab(),
          PengaturanTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _pindahTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Jelajahi Indonesia',
          style: tema.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih destinasi wisata untuk melihat detailnya.',
          style: tema.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        for (final item in daftarItem)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Hero(
                tag: 'ikon-${item.nama}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor:
                  tema.colorScheme.primaryContainer,
                  child: Icon(
                    item.ikon,
                    color: tema.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(item.nama),
              subtitle: Text(item.deskripsi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: item,
                );
              },
            ),
          ),
      ],
    );
  }
}

class KatalogTab extends StatefulWidget {
  const KatalogTab({super.key});

  @override
  State<KatalogTab> createState() => _KatalogTabState();
}

class _KatalogTabState extends State<KatalogTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
  bool _tampil = true;
  int _hitung = 0;

  late final AnimationController _putar;

  @override
  void initState() {
    super.initState();

    _putar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Demo Animasi',
          style: tema.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Animasi implisit
        Text(
          '1. AnimatedContainer',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 200 : 100,
            height: 90,
            decoration: BoxDecoration(
              color: _besar
                  ? warna.primary
                  : warna.tertiaryContainer,
              borderRadius: BorderRadius.circular(
                _besar ? 40 : 8,
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _besar = !_besar);
            },
            child: const Text('Ubah bentuk'),
          ),
        ),

        const Divider(height: 32),

        // AnimatedSwitcher
        Text(
          '2. AnimatedSwitcher',
          style: tema.textTheme.titleMedium,
        ),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              '$_hitung',
              key: ValueKey(_hitung),
              style: tema.textTheme.displayMedium,
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _hitung++);
            },
            child: const Text('Tambah angka'),
          ),
        ),

        const Divider(height: 32),

        // Animasi eksplisit
        Text(
          '3. AnimationController',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: RotationTransition(
            turns: _putar,
            child: Icon(
              Icons.settings,
              size: 64,
              color: warna.primary,
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                if (_putar.isAnimating) {
                  _putar.stop();
                } else {
                  _putar.repeat();
                }
              });
            },
            child: Text(
              _putar.isAnimating ? 'Berhenti' : 'Putar',
            ),
          ),
        ),

        const Divider(height: 32),

        // AnimatedOpacity
        Text(
          '4. AnimatedOpacity',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          opacity: _tampil ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Card(
            color: warna.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Kartu Galeri Wisata',
                  style: tema.textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() => _tampil = !_tampil);
            },
            child: Text(
              _tampil ? 'Sembunyikan kartu' : 'Tampilkan kartu',
            ),
          ),
        ),

        const Divider(height: 32),

        Text(
          'Daftar Destinasi',
          style: tema.textTheme.titleMedium,
        ),
        for (final item in daftarItem)
          ListTile(
            leading: Icon(item.ikon),
            title: Text(item.nama),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: item,
              );
            },
          ),
      ],
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  Future<void> _simpanMode(bool gelap) async {
    themeMode.value =
    gelap ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeGelap', gelap);
  }

  Future<void> _simpanWarna(int index) async {
    seedColor.value = index;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('warnaTema', index);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pengaturan Tampilan',
          style: tema.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Mode gelap'),
          subtitle: const Text(
            'Simpan pilihan tema aplikasi',
          ),
          value: themeMode.value == ThemeMode.dark,
          onChanged: _simpanMode,
        ),
        const SizedBox(height: 16),
        Text(
          'Pilih warna tema',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < pilihanWarna.length; i++)
              GestureDetector(
                onTap: () => _simpanWarna(i),
                child: CircleAvatar(
                  backgroundColor: pilihanWarna[i],
                  child: seedColor.value == i
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tema akan tetap tersimpan ketika aplikasi dibuka kembali.',
          style: tema.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(item.nama)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'ikon-${item.nama}',
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor:
                  tema.colorScheme.primaryContainer,
                  child: Icon(
                    item.ikon,
                    size: 64,
                    color: tema.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item.nama,
                style: tema.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                item.deskripsi,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '404',
              style: tema.textTheme.displayLarge,
            ),
            Text(
              'Halaman tidak ditemukan',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              },
              child: const Text('Ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}