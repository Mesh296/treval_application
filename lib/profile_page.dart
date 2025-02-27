//profile_page
import 'package:flutter/material.dart';

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
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/profile_pic.jpg"),
              ),
              const SizedBox(height: 10),
              const Text("Tran Duc Minh",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Edit Profile"),
              ),
              const SizedBox(height: 20),
              const Text("My Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // Add a Grid/ListView for posts
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("LOG OUT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}