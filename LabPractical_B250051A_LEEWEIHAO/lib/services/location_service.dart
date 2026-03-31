import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  bool isWithinRadius(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
    double radius,
  ) {
    final distance = calculateDistance(startLat, startLng, endLat, endLng);
    return distance <= radius;
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }
  }

  Future<Position> getCurrentLocation() async {
    await _checkPermission();

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      if (position.latitude == 0 && position.longitude == 0) {
        return "Invalid coordinates";
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return "Unknown location";
      }

      final place = placemarks.first;
      return _formatAddress(place);
    } catch (e) {
      return "Address unavailable";
    }
  }

  String _formatAddress(Placemark place) {
    return [
      place.name,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((element) => element != null && element.isNotEmpty).join(", ");
  }

  Future<Map<String, dynamic>> getFullLocationData() async {
    final position = await getCurrentLocation();
    final address = await getAddressFromCoordinates(position);

    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "address": address,
    };
  }
}