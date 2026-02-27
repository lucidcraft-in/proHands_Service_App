import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check and request location permissions
  static Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return false;
    }

    return true;
  }

  /// Get current coordinates
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      debugPrint('No location permission.');
      return null;
    }

    try {
      debugPrint('Fetching current position...');
      // Using a timeout to prevent hanging
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      // If high accuracy fails or times out, try last known position
      try {
        debugPrint('High accuracy failed, trying last known position...');
        return await Geolocator.getLastKnownPosition();
      } catch (e2) {
        debugPrint('Error getting last known position: $e2');
        return null;
      }
    }
  }

  /// Get address details from coordinates
  static Future<Map<String, String>?> getAddressFromLatLng(
    double lat,
    double lng,
  ) async {
    try {
      debugPrint('Fetching address for Lat: $lat, Lng: $lng...');
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        debugPrint('Found address: ${place.street}');
        return {
          'address':
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}'
                  .replaceAll(RegExp(r',\s*,'), ',')
                  .trim(),
          'locality': place.locality ?? '',
          'administrativeArea': place.administrativeArea ?? '',
          'zipcode': place.postalCode ?? '',
        };
      }
    } catch (e) {
      debugPrint('Error during geocoding: $e');
      return null;
    }
    return null;
  }
}
