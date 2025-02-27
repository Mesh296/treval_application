import 'package:flutter/material.dart';
import 'package:treval_application/main.dart';
import 'package:treval_application/sign_up_page.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SIGN IN",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Simulate successful sign in
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0037CF), // Blue color #0037CF
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "SIGN IN",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SignUpPage()),
                      );
                    },
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(color: Color(0xFF0037CF)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}