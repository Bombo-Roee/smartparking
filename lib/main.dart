import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatelessWidget {
  const SmartParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking Hadera Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ParkingHome(),
    );
  }
}

// מודל נתונים מורחב לחניון
class ParkingLocation {
  final String id;
  final String name;
  final String address;
  String status;
  Color statusColor;
  int spotsCount;
  final double lat;
  final double lng;
  final String pricePerHour;
  final bool hasCharging;
  final bool isAccessible;
  bool isFavorite;

  ParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.statusColor,
    required this.spotsCount,
    required this.lat,
    required this.lng,
    required this.pricePerHour,
    required this.hasCharging,
    required this.isAccessible,
    this.isFavorite = false,
  });

  String get spotsText => spotsCount > 0 ? '$spotsCount מקומות פנויים' : '0 מקומות פנויים';
}

class ParkingHome extends StatefulWidget {
  const ParkingHome({super.key});

  @override
  State<ParkingHome> createState() => _ParkingHomeState();
}

class _ParkingHomeState extends State<ParkingHome> {
  // רשימת החניונים הראשונית
  final List<ParkingLocation> _allParkingLots = [
    ParkingLocation(
      id: '1',
      name: 'מתחם וילג\' חדרה (Village)',
      address: 'כביש 4, צומת חדרה',
      status: 'פנוי ברובו',
      statusColor: Colors.green,
      spotsCount: 52,
      lat: 32.4340,
      lng: 34.9190,
      pricePerHour: 'חינם בשעות הראשונות',
      hasCharging: true,
      isAccessible: true,
    ),
    ParkingLocation(
      id: '2',
      name: 'קניון לב חדרה',
      address: 'הרברט סמואל 74, חדרה',
      status: 'כמעט מלא',
      statusColor: Colors.orange,
      spotsCount: 8,
      lat: 32.4320,
      lng: 34.9150,
      pricePerHour: '₪15 לשעה',
      hasCharging: false,
      isAccessible: true,
    ),
    ParkingLocation(
      id: '3',
      name: 'מתחם מול הים / פארק עסקים אנרג\'י',
      address: 'מערב חדרה',
      status: 'פנוי',
      statusColor: Colors.green,
      spotsCount: 120,
      lat: 32.4410,
      lng: 34.8890,
      pricePerHour: '₪10 לשעה',
      hasCharging: true,
      isAccessible: true,
    ),
    ParkingLocation(
      id: '4',
      name: 'חניון רכבת חדרה מערב',
      address: 'אזור התעשייה מערב',
      status: 'מלא לחלוטין',
      statusColor: Colors.red,
      spotsCount: 0,
      lat: 32.4380,
      lng: 34.8950,
      pricePerHour: '₪20 ליום שלם (לנוסעי רכבת)',
      hasCharging: false,
      isAccessible: true,
    ),
  ];

  String _searchQuery = '';
  bool _showOnlyFavorites = false;
  bool _isRefreshing = false;

  // פונקציה לפתיחת ניווט ב-Waze או Google Maps
  Future<void> _openNavigation(double lat, double lng, String name) async {
    final Uri wazeUri = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(wazeUri)) {
        await launchUrl(wazeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch maps');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  // סימולציית לייב לעדכון נתונים אקראי
  void _simulateLiveUpdate() {
    setState(() {
      _isRefreshing = true;
      final random = Random();
      for (var lot in _allParkingLots) {
        int change = random.nextInt(11) - 5; // שינוי בין -5 ל-+5
        lot.spotsCount = (lot.spotsCount + change).clamp(0, 150);
        
        if (lot.spotsCount == 0) {
          lot.status = 'מלא לחלוטין';
          lot.statusColor = Colors.red;
        } else if (lot.spotsCount < 10) {
          lot.status = 'כמעט מלא';
          lot.statusColor = Colors.orange;
        } else {
          lot.status = 'פנוי ברובו';
          lot.statusColor = Colors.green;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // סינון החניונים לפי חיפוש ומועדפים
    List<ParkingLocation> filteredLots = _allParkingLots.where((lot) {
      final matchesSearch = lot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lot.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorite = _showOnlyFavorites ? lot.isFavorite : true;
      return matchesSearch && matchesFavorite;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('חניונים חכמים - חדרה Pro'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
            color: _showOnlyFavorites ? Colors.redAccent : Colors.white,
            tooltip: 'הצג מועדפים בלבד',
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
          ),
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'סימולציית עדכון לייב',
            onPressed: _simulateLiveUpdate,
          ),
        ],
      ),
      body: Column(
        children: [
          // שדה חיפוש
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'חפש חניון או כתובת...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // רשימת החניונים
          Expanded(
            child: filteredLots.isEmpty
                ? const Center(
                    child: Text(
                      'לא נמצאו חניונים תואמים',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredLots.length,
                    itemBuilder: (context, index) {
                      final parking = filteredLots[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ParkingCard(
                          parking: parking,
                          onFavoriteToggle: () {
                            setState(() {
                              parking.isFavorite = !parking.isFavorite;
                            });
                          },
                          onNavigate: () {
                            _openNavigation(parking.lat, parking.lng, parking.name);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParkingDetailScreen(parking: parking),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// כרטיסיית חניון ראשית
class ParkingCard extends StatelessWidget {
  final ParkingLocation parking;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onNavigate;
  final VoidCallback onTap;

  const ParkingCard({
    super.key,
    required this.parking,
    required this.onFavoriteToggle,
    required this.onNavigate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            parking.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            parking.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 22,
                          ),
                          onPressed: onFavoriteToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parking.address,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          parking.spotsText,
                          style: TextStyle(
                            fontSize: 14,
                            color: parking.spotsCount == 0 ? Colors.red : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: onNavigate,
                          icon: const Icon(Icons.navigation, size: 14),
                          label: const Text('נווט', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: parking.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: parking.statusColor, width: 2),
                ),
                child: Text(
                  parking.status,
                  style: TextStyle(
                    color: parking.statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// מסך פרטי חניון מורחב
class ParkingDetailScreen extends StatelessWidget {
  final ParkingLocation parking;

  const ParkingDetailScreen({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parking.name),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parking.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              parking.address,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 30),
            _infoRow(Icons.local_parking, 'מצב תפוסה: ${parking.status}'),
            const SizedBox(height: 12),
            _infoRow(Icons.event_available, parking.spotsText),
            const SizedBox(height: 12),
            _infoRow(Icons.attach_money, 'תעריף: ${parking.pricePerHour}'),
            const SizedBox(height: 12),
            _infoRow(
              Icons.ev_station,
              parking.hasCharging ? 'יש עמדות טעינה לרכב חשמלי' : 'אין עמדות טעינה בחניון זה',
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.accessible,
              parking.isAccessible ? 'נגיש לבעלי מוגבלויות' : 'אין גישה מותאמת',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  final Uri wazeUri = Uri.parse('https://waze.com/ul?ll=${parking.lat},${parking.lng}&navigate=yes');
                  launchUrl(wazeUri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.navigation),
                label: const Text('התחל ניווט ב-Waze', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}