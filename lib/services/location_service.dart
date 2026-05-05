import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationInfo {
  final String ip;
  final String country;
  final String city;

  const LocationInfo({
    required this.ip,
    required this.country,
    required this.city,
  });

  static const empty = LocationInfo(ip: '', country: '', city: '');
}

class LocationService {
  static const _ipLookupTimeout = Duration(seconds: 6);

  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied. Enable them in settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Best-effort IP geolocation via ipapi.co. Failures return [LocationInfo.empty]
  /// so that report submission is never blocked by a third-party outage.
  Future<LocationInfo> getLocationInfo() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(_ipLookupTimeout);
      if (response.statusCode != 200) return LocationInfo.empty;
      final data = json.decode(response.body) as Map<String, dynamic>;
      return LocationInfo(
        ip: (data['ip'] ?? '').toString(),
        country: (data['country_name'] ?? '').toString(),
        city: (data['city'] ?? '').toString(),
      );
    } catch (_) {
      return LocationInfo.empty;
    }
  }
}
