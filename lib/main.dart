import 'package:flutter/material.dart';

void main() {
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ParkingHome(),
    );
  }
}

class ParkingHome extends StatelessWidget {
  const ParkingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('חניונים חכמים בזמן אמת'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ParkingCard(
            name: 'קניון עופר (הקניון הגדול)',
            status: 'פנוי ברובו (אור ירוק)',
            statusColor: Colors.green,
            spots: '45 מקומות פנויים',
          ),
          SizedBox(height: 12),
          ParkingCard(
            name: 'חניון מרכז העיר',
            status: 'כמעט מלא (צהוב)',
            statusColor: Colors.orange,
            spots: '5 מקומות פנויים',
          ),
          SizedBox(height: 12),
          ParkingCard(
            name: 'חניון הסינמה סיטי',
            status: 'מלא לחלוטין (אור אדום)',
            statusColor: Colors.red,
            spots: '0 מקומות פנויים',
          ),
        ],
      ),
    );
  }
}

class ParkingCard extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final String spots;

  const ParkingCard({
    super.key,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.spots,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  spots,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}