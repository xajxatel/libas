// login_register_screen.dart

import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginRegisterScreen extends ConsumerStatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showDialog("ERROR", "Please enter your email address.");
      return;
    }

    final result = await ref.read(authProvider.notifier).resetPassword(email);
    if (result == 'Password reset email sent') {
      _showDialog("PASSWORD RESET",
          "Check your email for password reset instructions.");
    } else if (result == 'Email not registered') {
      _showDialog("ERROR", "The email address is not registered.");
    } else {
      _showDialog("ERROR", result ?? 'An error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _emailController,
                      cursorColor: Colors.black,
                      decoration: _buildInputDecoration('EMAIL'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      cursorColor: Colors.black,
                      decoration: _buildInputDecoration('PASSWORD'),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: authState.isLoading
                        ? const Center(
                            child: LoadingCircle(),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();

                                    if (!_isValidEmail(email)) {
                                      _showDialog('INVALID EMAIL',
                                          'Use a valid email address.');
                                      return;
                                    }

                                    if (!_isValidPassword(password)) {
                                      _showDialog('INVALID PASSWORD',
                                          'Password should be at least 6 characters.');
                                      return;
                                    }

                                    if (_isLoginMode) {
                                      final result =
                                          await _handleLogin(email, password);
                                      if (result != null) {
                                        _showDialog('ERROR', result);
                                      }
                                    } else {
                                      final result = await _handleRegister(
                                          email, password);
                                      if (result != null) {
                                        _showDialog('ERROR', result);
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.black, width: 1.0),
                                    backgroundColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: Text(
                                    _isLoginMode ? 'LOGIN' : 'JOIN',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              if (_isLoginMode)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _handleForgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'FORGOT PASSWORD?',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
          // Move the "Don't have an account? / Already a member?" to the bottom
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLoginMode ? "DON'T HAVE AN ACCOUNT?" : "ALREADY A MEMBER?",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                    });
                  },
                  child: Text(
                    _isLoginMode ? "CREATE" : "LOGIN",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      isDense: true,
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        height: 1.0,
      ),
      contentPadding: const EdgeInsets.only(bottom: 0.0),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<String?> _handleLogin(String email, String password) async {
    final result = await ref
        .read(authProvider.notifier)
        .loginUser(email, password, context);
    if (result == 'Invalid credentials') {
      return 'Entered email or password is incorrect.';
    } else if (result == 'Unverified email') {
      return 'Verify your email to continue.';
    } else if (result == 'Login error') {
      return 'An error occurred during login. Please try again.';
    }
    return null;
  }

  Future<String?> _handleRegister(String email, String password) async {
    final result = await ref
        .read(authProvider.notifier)
        .registerUser(email, password, context);
    if (result == 'Email in use') {
      return 'This email is already in use. Please login to continue.';
    } else if (result == 'Verification') {
      return 'Please verify your email to login.';
    } else if (result == 'Registration error') {
      return 'An error occurred during registration. Please try again.';
    }
    return null;
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: const EdgeInsets.all(8.0),
        titlePadding: const EdgeInsets.all(8.0),
        actionsPadding: const EdgeInsets.only(bottom: 4.0),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.left,
        ),
        content: Text(
          content.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 12.0,
          ),
          textAlign: TextAlign.left,
        ),
        actions: [
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
