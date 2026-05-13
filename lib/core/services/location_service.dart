import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationService {
  static const String _googleApiKey = "AIzaSyA1v4mq57HE_83ptDaF12R9lWxqGn2xI1k";

  /// Get directions between two points
  static Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Decode polyline points
          final polylineString = route['overview_polyline']['points'];
          final List<PointLatLng> result = PolylinePoints.decodePolyline(
            polylineString,
          );

          final List<LatLng> points =
              result.map((p) => LatLng(p.latitude, p.longitude)).toList();

          return {
            'points': points,
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'duration_seconds': leg['duration']['value'],
            'distance_meters': leg['distance']['value'],
          };
        } else {
          final String errMsg =
              data['error_message'] ?? 'No detailed error provided';
          debugPrint('Directions API error: ${data['status']}');
          debugPrint('Reason: $errMsg');
        }
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
    }
    return null;
  }

  /// Centralized location permission handler with UI dialogs
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Location Services Disabled'),
                content: const Text(
                  'Please enable location services to continue.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Geolocator.openLocationSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Enable'),
                  ),
                ],
              ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Location Permission Denied'),
                content: const Text(
                  'Location permissions are permanently denied. Please enable them in settings to continue.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Geolocator.openAppSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
        );
      }
      return false;
    }

    return true;
  }

  /// Check and request location permissions (Non-UI version)
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
  static Future<Position?> getCurrentPosition([BuildContext? context]) async {
    bool hasPermission;
    if (context != null) {
      hasPermission = await handleLocationPermission(context);
    } else {
      hasPermission = await checkPermission();
    }

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
        debugPrint('Found address: ${place.name}');
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

  /// Get place suggestions from Google Places API
  static Future<List<Map<String, dynamic>>> getPlaceSuggestions(
    String input,
  ) async {
    if (input.isEmpty) return [];

    final String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey&types=geocode";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['predictions']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching place suggestions: $e');
    }
    return [];
  }

  /// Get Lat/Lng from Google Place Details API
  static Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final lat = data['result']['geometry']['location']['lat'];
          final lng = data['result']['geometry']['location']['lng'];
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
    return null;
  }
}
