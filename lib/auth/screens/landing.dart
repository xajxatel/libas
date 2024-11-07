import 'package:flutter/material.dart';
import 'login_register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at the top
          SizedBox(height: screenHeight * 0.06),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Image.asset(
              'assets/logo14.png',
              width: screenWidth * 0.85,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          // Grey divider line
          Container(
            width: screenWidth,
            margin: const EdgeInsets.only(top: 10.0),
            child: const Divider(
              color: Colors.grey,
              thickness: 1.0,
            ),
          ),
          // "JOIN" button aligned to the right below the divider
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginRegisterScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0), // Reduced padding
                  minimumSize:
                      const Size(80, 36), // Set button width and height
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Pointy rectangular shape
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  "JOIN",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          // Expanded background image that fills the remaining space below the content
          Expanded(
            child: Image.asset(
              'assets/back8.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}