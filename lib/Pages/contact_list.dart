import 'package:flutter/material.dart';
import 'package:front_end_medicai/Pages/chat_page.dart';

class ContactListPage extends StatelessWidget {
  ContactListPage({Key? key}) : super(key: key);

  // Data dummy dokter
  final List<Map<String, String>> doctors = [
    {
      'id': '1',
      'name': 'Dr. Siti Aminah',
      'image': 'assets/doktor.png',
    },
    {
      'id': '2',
      'name': 'Dr. Budi Santoso',
      'image': 'assets/doktor.png',
    },
    {
      'id': '3',
      'name': 'Dr. Andi Wijaya',
      'image': 'assets/doktor.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Dokter'),
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(doctor['image']!),
              radius: 25,
            ),
            title: Text(
              doctor['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    doctorName: doctor['name']!,
                    doctorId: doctor['id']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
