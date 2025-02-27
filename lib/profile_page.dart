//profile_page
import 'package:flutter/material.dart';
import 'package:treval_application/sign_in_page.dart'; // Replace with your app's package name

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/profile_pic.jpg"),
              ),
              SizedBox(height: 10),
              Text(
                "Tran Duc Minh",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Add edit profile logic here
                },
                child: Text("Edit Profile"),
              ),
              SizedBox(height: 20),
              Text(
                "My Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Logout function
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SignInPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("LOG OUT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}