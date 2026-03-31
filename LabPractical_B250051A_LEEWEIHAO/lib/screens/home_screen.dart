import 'package:flutter/material.dart';
import '/services/location_service.dart';
import '/services/checkin_service.dart';
import 'history_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationText = 'No location.';
  String statusText = 'Checking...';

  double? currentLat;
  double? currentLng;

  int totalPoints = 0;

  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> fairs = [
    {
      "name": "Education Fair",
      "location": "Southern University College, Skudai, Johor",
      "lat": 1.533333,
      "lng": 103.681667,
      "radius": 200.0,
      "points": 10,
    },
    {
      "name": "Career Expo",
      "location": "Universiti Teknologi Malaysia, Johor Bahru, Johor",
      "lat": 1.558433,
      "lng": 103.638367,
      "radius": 200.0,
      "points": 15,
    },
    {
      "name": "Job Fair",
      "location": "Sutera Mall, Skudai, Johor",
      "lat": 1.517651,
      "lng": 103.671549,
      "radius": 200.0,
      "points": 20,
    },
  ];

  Map<String, dynamic>? nearestFair;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadTotalPoints();
  }

  Future<void> _loadTotalPoints() async {
    final points = await CheckInService.getTotalPoints();
    setState(() {
      totalPoints = points;
    });
  }

  Map<String, dynamic> _findNearestFair(double userLat, double userLng) {
    final locationService = LocationService();

    Map<String, dynamic> nearest = fairs.first;
    double minDistance = locationService.calculateDistance(
      userLat,
      userLng,
      nearest["lat"],
      nearest["lng"],
    );

    for (var fair in fairs) {
      double distance = locationService.calculateDistance(
        userLat,
        userLng,
        fair["lat"],
        fair["lng"],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = fair;
      }
    }

    return nearest;
  }

  Future<void> _getLocation() async {
    setState(() {
      locationText = "Getting location...";
      statusText = "Checking...";
    });

    try {
      final locationService = LocationService();

      final position = await locationService.getCurrentLocation();

      final fair = _findNearestFair(position.latitude, position.longitude);

      final isAtFair = locationService.isWithinRadius(
        position.latitude,
        position.longitude,
        fair["lat"],
        fair["lng"],
        fair["radius"],
      );

      setState(() {
        currentLat = position.latitude;
        currentLng = position.longitude;
        nearestFair = fair;
        locationText = fair["location"];
        statusText = isAtFair ? "At Fair" : "Not At Fair";
      });

      _goToCurrentLocation();
    } catch (e) {
      setState(() {
        locationText = "Error getting location";
        statusText = "Unable to validate";
      });
    }
  }

  void _goToCurrentLocation() {
    if (currentLat == null || currentLng == null) return;

    _mapController.move(
      LatLng(currentLat!, currentLng!),
      16,
    );
  }

  Future<void> joinFair() async {
    if (currentLat == null || currentLng == null || nearestFair == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not ready")),
      );
      return;
    }

    final locationService = LocationService();

    final isAtFair = locationService.isWithinRadius(
      currentLat!,
      currentLng!,
      nearestFair!["lat"],
      nearestFair!["lng"],
      nearestFair!["radius"],
    );

    if (!isAtFair) {
      setState(() {
        statusText = "Not At Fair";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text("Join Fair Unsuccessful: Outside Fair Area"),
          ),
        ),
      );
      return;
    }

    bool alreadyJoined = await CheckInService.hasCheckedInToday(
      nearestFair!["name"],
    );

    if (alreadyJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text("You have already joined this fair today"),
          ),
        ),
      );
      return;
    }

    await CheckInService.addCheckIn(
      nearestFair!["name"],
      nearestFair!["location"],
      nearestFair!["points"],
    );

    final updatedPoints = await CheckInService.getTotalPoints();

    setState(() {
      statusText = "At Fair";
      totalPoints = updatedPoints;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Center(child: Text("Join Fair Successful"))),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Widget child,
    Color iconColor = const Color(0xFF1D4ED8),
    Color bgColor = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fairLat = nearestFair?["lat"] ?? 1.558433;
    final fairLng = nearestFair?["lng"] ?? 103.638367;
    final fairRadius = nearestFair?["radius"] ?? 200.0;
    final isAtFairNow = statusText == "At Fair";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fair Participation",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nearestFair?["name"] ?? "Detecting nearest fair...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Stack(
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        currentLat ?? fairLat,
                        currentLng ?? fairLng,
                      ),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName:
                            'com.example.fair_participation_app',
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(fairLat, fairLng),
                            radius: fairRadius,
                            useRadiusInMeter: true,
                            color:
                                const Color(0xFF2563EB).withOpacity(0.18),
                            borderColor: const Color(0xFF2563EB),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          ...fairs.map(
                            (fair) => Marker(
                              point: LatLng(fair["lat"], fair["lng"]),
                              width: 32,
                              height: 32,
                              child: const Icon(
                                Icons.location_on,
                                color: Color(0xFF10B981),
                                size: 30,
                              ),
                            ),
                          ),
                          Marker(
                            point: LatLng(
                              currentLat ?? fairLat,
                              currentLng ?? fairLng,
                            ),
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Color(0xFFDC2626),
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _goToCurrentLocation,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.my_location,
                          color: Color(0xFF1D4ED8),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.place_rounded,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFF8FBFF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Address",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locationText,
                    style: const TextStyle(
                      height: 1.4,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.event_note_rounded,
              iconColor: const Color(0xFF7C3AED),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nearest Fair Information",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.event,
                          size: 18, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nearestFair?["name"] ?? "-",
                          style:
                              const TextStyle(color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_city,
                          size: 18, color: Color(0xFF0F766E)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nearestFair?["location"] ?? "-",
                          style:
                              const TextStyle(color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 18, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Text(
                        "Points: ${nearestFair?["points"] ?? "-"}",
                        style:
                            const TextStyle(color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isAtFairNow
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAtFairNow
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isAtFairNow
                              ? Icons.verified_rounded
                              : Icons.cancel_rounded,
                          color: isAtFairNow
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isAtFairNow
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFD97706),
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Total Points",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$totalPoints",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _getLocation,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Refresh Location"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await joinFair();
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text("Join Fair"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded),
                label: const Text("View History"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: BorderSide(color: Colors.grey.shade300),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}