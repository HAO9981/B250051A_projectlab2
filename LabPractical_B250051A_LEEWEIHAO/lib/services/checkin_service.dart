import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CheckInService {
  static const String historyKey = "fair_history";
  static const String totalPointsKey = "total_points";

  static Future<void> addCheckIn(String fairName, String location, int points) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(historyKey) ?? [];

    String formattedTime =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

      final newEntry = jsonEncode({
        "fairName": fairName,
        "location": location,
        "points": points,
        "time": formattedTime,
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

    history.add(newEntry);
    await prefs.setStringList(historyKey, history);

    int currentPoints = prefs.getInt(totalPointsKey) ?? 0;
    currentPoints += points;
    await prefs.setInt(totalPointsKey, currentPoints);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> history = prefs.getStringList(historyKey) ?? [];

    return history
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  static Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(totalPointsKey) ?? 0;
  }

  static Future<bool> hasCheckedInToday(String fairName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(historyKey) ?? [];

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (String item in history) {
      final record = jsonDecode(item) as Map<String, dynamic>;

      if (record["fairName"] == fairName && record["date"] == today) {
        return true;
      }
    }

    return false;
  }
}