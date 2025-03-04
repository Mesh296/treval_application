//create_trip_page
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateTripPage extends StatelessWidget {
  const CreateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar with a back button
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.black), // Back button
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center the "Information Trip" text
                const Center(
                  child: Text(
                    'Information Trip',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('Choose your location'),
                const SizedBox(height: 20),
                _buildTextField('Choose date'),
                const SizedBox(height: 20),
                _buildTextField('Budget per day per person'),
                const SizedBox(height: 20),
                _buildTextField('Trip\'s description'),
                const SizedBox(height: 20),
                _buildTextField('Trip Name'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle the start trip action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0037CF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity,
                          50), // Expands horizontally, sets height to 50
                      padding: const EdgeInsets.symmetric(
                          vertical: 10), // Adjust vertical padding
                    ),
                    child: Text(
                      "START MY TRIP",
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
Widget _buildTextField(String hintText) {
  return TextField(
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
      ),
      filled: true,
      fillColor: Colors.transparent, // Match the background color
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey[400]!, // Bottom border color
          width: 1.0,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF0037CF), // Bottom border color when focused
          width: 2.0,
        ),
      ),
    ),
  );
}
}
