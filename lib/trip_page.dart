//trip_page
import 'package:flutter/material.dart';

class TripPage extends StatelessWidget {
  const TripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Add this to make the Column scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ongoing Trip", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.asset(
                          "assets/images/petersburg.jpg",
                          height: 150,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text("Saint Petersburg Trip 2020", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("14 Feb - 25 Feb", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("+ CREATE NEW TRIP", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                Text("Past Trips", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true, // Add this to make GridView take only the space it needs
                    physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling since it's inside SingleChildScrollView
                    children: [
                      _buildPastTripCard("Murmansk, Russia", "5 months ago", "assets/images/murmansk.jpg"),
                      _buildPastTripCard("Tokyo, Japan", "8 months ago", "assets/images/tokyo.jpg"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastTripCard(String location, String date, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(location, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(date, style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}