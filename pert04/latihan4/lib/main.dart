import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}


class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

// ======================================================
// MODEL KOMENTAR
// ======================================================

class Komentar {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  const Komentar({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      postId: json['postId'] as int,
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

// ======================================================
// API SERVICE
// ======================================================

class ApiService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  // ====================================================
  // MENGAMBIL SEMUA POSTINGAN
  // ====================================================

  static Future<List<Post>> ambilPosts() async {
    final uri = Uri.parse('$baseUrl/posts');

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat postingan '
            '(kode ${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (e) => Post.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  // ====================================================
  // MENGAMBIL KOMENTAR BERDASARKAN ID POST
  // ====================================================

  static Future<List<Komentar>> ambilKomentar(
      int postId,
      ) async {
    final uri = Uri.parse(
      '$baseUrl/posts/$postId/comments',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat komentar '
            '(kode ${response.statusCode})',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (e) => Komentar.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}

// ======================================================
// APLIKASI
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Postingan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PostPage(),
    );
  }
}

// ======================================================
// HALAMAN DAFTAR POSTINGAN
// ======================================================

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late Future<List<Post>> _futurePosts;

  @override
  void initState() {
    super.initState();

    _futurePosts = ApiService.ambilPosts();
  }

  // ====================================================
  // MEMUAT ULANG POSTINGAN
  // ====================================================

  void _muatUlang() {
    setState(() {
      _futurePosts = ApiService.ambilPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),

      // ==================================================
      // FUTUREBUILDER POST
      // ==================================================

      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          // ==============================================
          // LOADING
          // ==============================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==============================================
          // ERROR
          // ==============================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi kesalahan:\n'
                          '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _muatUlang,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==============================================
          // DATA
          // ==============================================

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada postingan',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${post.id}',
                    ),
                  ),
                  title: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPostPage(
                          post: post,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ======================================================
// HALAMAN DETAIL POSTINGAN
// ======================================================

class DetailPostPage extends StatefulWidget {
  final Post post;

  const DetailPostPage({
    super.key,
    required this.post,
  });

  @override
  State<DetailPostPage> createState() =>
      _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();

    // Future kedua untuk mengambil komentar
    _futureKomentar =
        ApiService.ambilKomentar(widget.post.id);
  }

  // ====================================================
  // MEMUAT ULANG KOMENTAR
  // ====================================================

  void _muatUlangKomentar() {
    setState(() {
      _futureKomentar =
          ApiService.ambilKomentar(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =================================================
          // JUDUL
          // =================================================

          Text(
            widget.post.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // =================================================
          // ISI LENGKAP
          // =================================================

          Text(
            widget.post.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          const Divider(),

          const SizedBox(height: 12),

          // =================================================
          // JUDUL KOMENTAR
          // =================================================

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _muatUlangKomentar,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // =================================================
          // FUTUREBUILDER KOMENTAR
          // =================================================

          FutureBuilder<List<Komentar>>(
            future: _futureKomentar,
            builder: (context, snapshot) {
              // ============================================
              // LOADING KOMENTAR
              // ============================================

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // ============================================
              // ERROR KOMENTAR
              // ============================================

              if (snapshot.hasError) {
                return Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat komentar:\n'
                          '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muatUlangKomentar,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                );
              }

              // ============================================
              // DATA KOMENTAR
              // ============================================

              final komentar =
                  snapshot.data ?? [];

              if (komentar.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Belum ada komentar',
                    ),
                  ),
                );
              }

              return Column(
                children: komentar.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          item.name[0].toUpperCase(),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item.email,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.body,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}