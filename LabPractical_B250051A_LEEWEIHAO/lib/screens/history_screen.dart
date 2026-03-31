import 'package:flutter/material.dart';
import '/services/checkin_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await CheckInService.getHistory();
    setState(() {
      history = data.reversed.toList();
    });
  }

  int get totalPoints {
    int total = 0;
    for (var item in history) {
      total += (item["points"] as int? ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Fair History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 56,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "No fair participation yet",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Your joined fairs will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                          Icons.emoji_events_rounded,
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
                              "Participation Summary",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${history.length} joined fair(s) • $totalPoints points",
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

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                color: Color(0xFF1D4ED8),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["fairName"] ?? "-",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.place_rounded,
                                        size: 16,
                                        color: Color(0xFF0F766E),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item["location"] ?? "-",
                                          style: const TextStyle(
                                            color: Color(0xFF475569),
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item["time"] ?? "-",
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: Text(
                                "+${item["points"]}",
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
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