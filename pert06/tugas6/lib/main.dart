
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<int>(0);

class Wisata {
  final String nama;
  final String lokasi;
  final String deskripsi;
  final IconData ikon;

  const Wisata(this.nama, this.lokasi, this.deskripsi, this.ikon);
}

const daftarWisata = [
  Wisata('Pantai Bali', 'Bali, Indonesia',
      'Pantai dengan pemandangan laut yang indah dan matahari terbenam.',
      Icons.beach_access),
  Wisata('Gunung Bromo', 'Jawa Timur, Indonesia',
      'Destinasi pegunungan dengan pemandangan matahari terbit.',
      Icons.landscape),
  Wisata('Candi Borobudur', 'Magelang, Indonesia',
      'Candi bersejarah dengan arsitektur dan relief yang menarik.',
      Icons.account_balance),
  Wisata('Raja Ampat', 'Papua Barat Daya, Indonesia',
      'Wisata bahari dengan pulau-pulau indah dan kekayaan bawah laut.',
      Icons.sailing),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData buatTema(Color warna, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: warna,
      brightness: brightness,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Wisata Indonesia',
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
              final data = settings.arguments;

              if (data is! Wisata) {
                return MaterialPageRoute<void>(
                  builder: (_) => const NotFoundPage(),
                );
              }

              return PageRouteBuilder<void>(
                settings: settings,
                pageBuilder: (_, animation, secondaryAnimation) {
                  return DetailPage(wisata: data);
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

// NAVIGASI UTAMA

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const judul = [
    'Beranda',
    'Katalog Wisata',
    'Pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme.primaryContainer,
                ),
                child: Text(
                  'Wisata Indonesia',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Beranda'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore),
                title: const Text('Katalog Wisata'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 2);
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
        onDestinationSelected: (i) {
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
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

// BERANDA

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          'Jelajahi Keindahan Indonesia',
          style: tema.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Temukan destinasi wisata favoritmu.',
          style: tema.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Center(
          child: RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.explore,
              size: 80,
              color: warna.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: warna.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Indonesia memiliki banyak destinasi wisata alam dan budaya yang menarik.',
              style: tema.textTheme.titleMedium?.copyWith(
                color: warna.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Destinasi Pilihan',
          style: tema.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        for (final wisata in daftarWisata.take(2))
          ListTile(
            leading: Icon(wisata.ikon),
            title: Text(wisata.nama),
            subtitle: Text(wisata.lokasi),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: wisata,
              );
            },
          ),
      ],
    );
  }
}

// KATALOG

class KatalogTab extends StatefulWidget {
  const KatalogTab({super.key});

  @override
  State<KatalogTab> createState() => _KatalogTabState();
}

class _KatalogTabState extends State<KatalogTab> {
  bool _besar = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Katalog Wisata',
          style: tema.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Tekan destinasi untuk melihat detail.',
          style: tema.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 220 : 120,
            height: 70,
            decoration: BoxDecoration(
              color: _besar
                  ? warna.primary
                  : warna.tertiaryContainer,
              borderRadius:
              BorderRadius.circular(_besar ? 35 : 8),
            ),
            child: Center(
              child: Text(
                'Wisata Indonesia',
                style: tema.textTheme.labelLarge?.copyWith(
                  color: _besar
                      ? warna.onPrimary
                      : warna.onTertiaryContainer,
                ),
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
        for (final wisata in daftarWisata)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Hero(
                tag: 'wisata-${wisata.nama}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: warna.primaryContainer,
                  child: Icon(
                    wisata.ikon,
                    color: warna.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(wisata.nama),
              subtitle: Text(wisata.lokasi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: wisata,
                );
              },
            ),
          ),
      ],
    );
  }
}

// PENGATURAN

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  Future<void> simpanMode(bool gelap) async {
    themeMode.value =
    gelap ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeGelap', gelap);
  }

  Future<void> simpanWarna(int index) async {
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
          subtitle: const Text('Aktifkan tema gelap'),
          value: themeMode.value == ThemeMode.dark,
          onChanged: simpanMode,
        ),
        const SizedBox(height: 16),
        Text(
          'Pilih Warna Tema',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (int i = 0; i < pilihanWarna.length; i++)
              GestureDetector(
                onTap: () => simpanWarna(i),
                child: CircleAvatar(
                  radius: 24,
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
        const SizedBox(height: 24),
        Text(
          'Pengaturan tetap tersimpan meskipun aplikasi ditutup.',
          style: tema.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// DETAIL WISATA

class DetailPage extends StatelessWidget {
  final Wisata wisata;

  const DetailPage({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(wisata.nama)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'wisata-${wisata.nama}',
              child: CircleAvatar(
                radius: 70,
                backgroundColor: warna.primaryContainer,
                child: Icon(
                  wisata.ikon,
                  size: 70,
                  color: warna.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            wisata.nama,
            style: tema.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            wisata.lokasi,
            style: tema.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                wisata.deskripsi,
                style: tema.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}

// HALAMAN 404

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman tidak ditemukan'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('404', style: tema.textTheme.displayLarge),
            const SizedBox(height: 8),
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
