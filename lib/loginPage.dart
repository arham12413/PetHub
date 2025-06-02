import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isCreatingAccount = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, IconData? icon, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.red.shade700) : null,
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.red.shade800),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } on FirebaseAuthException catch (e) {nm
      if (e.code == 'user-not-found') {
        _showSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showSnackBar('Incorrect password.');
      } else {
        _showSnackBar('Login failed. ${e.message}');
      }
    }
  }

  void _createAccount() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        _showSnackBar('Account created successfully!', color: Colors.green);

        // Delay for 1 second before navigating
        await Future.delayed(Duration(seconds: 1));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showSnackBar('Email is already in use.');
      } else {
        _showSnackBar('Signup failed. ${e.message}');
      }
    }
  }


  void _validateAndSubmit() {
    if (isCreatingAccount) {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          phoneController.text.isEmpty ||
          passwordController.text.isEmpty) {
        _showSnackBar('Please fill in all fields');
      } else {
        _createAccount();
      }
    } else {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        _showSnackBar('Please enter both email and password');
      } else {
        _login();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text('🐾 Pet Adoption App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  )),
              SizedBox(height: 30),
              Text(
                isCreatingAccount ? 'Create New Account' : 'Login',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700),
              ),
              SizedBox(height: 20),

              if (isCreatingAccount) ...[
                _buildTextField('Full Name', nameController, icon: Icons.person),
                _buildTextField('Phone Number', phoneController,
                    icon: Icons.phone, keyboardType: TextInputType.phone),
              ],

              _buildTextField('Email', emailController, icon: Icons.email),
              _buildTextField('Password', passwordController,
                  obscureText: true, icon: Icons.lock),

              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isCreatingAccount ? 'Create Account' : 'Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isCreatingAccount = !isCreatingAccount;
                  });
                },
                child: Text(
                  isCreatingAccount
                      ? 'Already have an account? Login'
                      : 'Create New Account',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}