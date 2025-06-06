import 'package:flutter/material.dart';
import 'package:front_end_medicai/Pages/login_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();

    // Redirect after 1 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(_fadeRoute(LoginPage()));
    });
  }

  //Fade Animation
  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF14AE5C),
      body: Column(
        children: [
          //logo
          Padding(
            padding: const EdgeInsets.only(
              left: 80.0,
              right: 80,
              bottom: 30,
              top: 200,
            ),
            child: Image.asset('assets/Component 1.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Your Health Companion",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'BreeSerif',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
