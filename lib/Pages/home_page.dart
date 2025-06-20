import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicai/Pages/login_page.dart';
import 'package:medicai/Pages/diagnose.dart';
import 'package:medicai/Pages/hospital_page.dart';
import 'package:medicai/Pages/History_page.dart';
import 'package:medicai/Pages/chat_log.dart';
import 'package:medicai/Pages/article_page.dart'; 
import 'package:medicai/Pages/article_detail_page.dart'; 
import 'package:medicai/Model/article.dart'; 
import '../Model/hospital_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String firstName = "User";
  List<Facility> hospitals = [];
  List<Article> articles = []; // Add this line
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _getLocationSimple();
    _loadSampleArticles(); 
  }

  void _loadSampleArticles() {
    setState(() {
      articles = Article.getSampleArticles().take(3).toList(); // Show only 3 articles on home page
    });
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          String fullName = userDoc['name']; // Get full name
          setState(() {
            firstName = fullName.split(' ')[0]; // Extract first name
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _getLocationSimple() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        print("Permission denied");
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition();
      print("Location: ${position.latitude}, ${position.longitude}");
      
      await fetchFacilities(position.latitude, position.longitude);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchFacilities(double? lan, double? long, {double radius = 5}) async {
    final url = Uri.parse(
      'http://192.168.0.70:8000/api/facilities/?lat=$lan&lon=$long&radius=$radius',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          hospitals = data.map((json) => Facility.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load facilities');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF14AE5C),
          title: const Text(
            'Logout Confirmation',
            style: TextStyle(fontFamily: 'BreeSerif', color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'BreeSerif', color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(fontFamily: 'BreeSerif', color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Color(0xFF3CB371),
                  ),
                );
              },
              child: const Text(
                'Yes',
                style: TextStyle(fontFamily: 'BreeSerif', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthMetric(String label, String imagePath) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon image
          Container(width: 40, height: 40, child: Image.asset(imagePath)),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3CB371),
              fontSize: 12,
              fontFamily: 'BreeSerif',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to build article cards
  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(
              title: article.title,
              imageUrl: article.imageUrl,
              category: article.category,
              date: article.date,
              author: article.author,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Article image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                article.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Article content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3CB371).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: Color(0xFF3CB371),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BreeSerif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Article title
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF5B8A72),
                        fontFamily: 'BreeSerif',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Article description
                    Text(
                      article.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontFamily: 'BreeSerif',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Date and read time
                    Row(
                      children: [
                        Text(
                          article.date,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 10,
                            fontFamily: 'BreeSerif',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${article.readTime} min read',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 10,
                            fontFamily: 'BreeSerif',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Header with logo and profile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo and greeting
                    Row(
                      children: [
                        // Heart logo with heartbeat
                        Container(
                          height: 40,
                          width: 40,
                          child: Image.asset('lib/Assets/Vector.png'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hello, $firstName',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'BreeSerif',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3CB371),
                          ),
                        ),
                      ],
                    ),
                    // Profile icon
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3CB371),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Health Record Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF3CB371),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "User's Health Record",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'BreeSerif',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Health Metrics Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHealthMetric(
                          'Blood Glucose Level',
                          'lib/Assets/image 1.png',
                        ),
                        _buildHealthMetric(
                          'Blood Pressure',
                          'lib/Assets/image 2.png',
                        ),
                        _buildHealthMetric(
                          'Cholestrol',
                          'lib/Assets/image 3.png',
                        ),
                        _buildHealthMetric(
                          'Uric Acid',
                          'lib/Assets/image 5.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Diagnosa Penyakit Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiagnosePage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 220,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3CB371),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Diagnosa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'BreeSerif',
                                    ),
                                  ),
                                  Text(
                                    'Penyakit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'BreeSerif',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 70,
                            child: Image.asset('lib/Assets/Frame 9.png'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Contact Dokter button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicAIChatApp(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Chat bubble icon
                          Container(
                            width: 120,
                            height: 70,
                            child: Image.asset('lib/Assets/Group 44.png'),
                          ),

                          // Contact Dokter button
                          Container(
                            width: 220,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8DE4B5),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Contact',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'BreeSerif',
                                    ),
                                  ),
                                  Text(
                                    'Dokter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'BreeSerif',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // History pages
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiagnosisHistoryPage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 220,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3CB371),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Riwayat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'BreeSerif',
                                    ),
                                  ),
                                  Text(
                                    'Diagnosa',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'BreeSerif',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 50,
                            child: Image.asset('lib/Assets/Riwayat.png'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Nearest Hospital section
                    const Text(
                      'RS Terdekat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B8A72),
                        fontFamily: 'BreeSerif',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hospital cards
                    SizedBox(
                      height: 290,
                      child:
                          hospitals.isEmpty
                              ? Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: hospitals.length,
                                itemBuilder: (context, index) {
                                  final hospital = hospitals[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => HospitalDetailPage(
                                                hospital: {
                                                  'name': hospital.name,
                                                  'address': hospital.address,
                                                  'type': hospital.type,
                                                  'photoUrl': hospital.photoUrl,
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ), // Matches container
                                        splashColor:
                                            Colors.grey
                                                .withValues(), // Ripple effect color
                                        highlightColor:
                                            Colors.grey
                                                .withValues(), // Press effect color
                                        child: Container(
                                          width: 190,
                                          margin: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Ensuring the image is at the top edge
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(12),
                                                    ),
                                                child: Image.memory(
                                                  base64Decode(
                                                    hospital.photoUrl!,
                                                  ),
                                                  height:
                                                      140, // Fixed height for consistency
                                                  width: double.infinity,
                                                  fit:
                                                      BoxFit
                                                          .cover, // Ensures the image fills the space
                                                  alignment:
                                                      Alignment.topCenter,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      hospital.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF5B8A72,
                                                        ),
                                                        fontFamily: 'BreeSerif',
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      hospital.address,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF5B8A72,
                                                        ),
                                                        fontFamily: 'BreeSerif',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 40),

                    // Articles section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Articles',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B8A72),
                            fontFamily: 'BreeSerif',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticlePage(),
                              ),
                            );
                          },
                          child: const Text(
                            'View More',
                            style: TextStyle(
                              color: Color(0xFF5B8A72),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'BreeSerif',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    
                    // Article cards - Replace the placeholder containers with actual article cards
                    Column(
                      children: articles.map((article) => _buildArticleCard(article)).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}