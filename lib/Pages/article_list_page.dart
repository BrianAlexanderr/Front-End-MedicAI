import 'package:flutter/material.dart';
import 'package:front_end_medicai/Pages/ariticle_detail_page.dart';

class ArticleListPage extends StatelessWidget {
  const ArticleListPage({super.key});

  final List<Map<String, String>> articles = const [
    {
      'title': 'Manfaat Makan Sehat',
      'image': 'assets/artikel 1.jpeg',
      'content': 'Isi artikel tentang manfaat makan sehat...',
    },
    {
      'title': 'Tips Olahraga Rutin',
      'image': 'assets/artikel 1.jpeg',
      'content': 'Isi artikel tentang tips olahraga rutin...',
    },
    // Tambah artikel lain di sini kalau mau
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Artikel'),
        backgroundColor: const Color(0xFF5B8A72),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailPage(
                    title: article['title']!,
                    content: article['content']!,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      article['image']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article['title']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
