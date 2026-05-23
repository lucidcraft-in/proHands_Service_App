import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import '../../features/service_boy/providers/service_boy_provider.dart';
import 'getCurrentLocation.dart';
import '../models/booking_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';
import '../widgets/custom_button.dart';

class MapScreen extends StatefulWidget {
  final BookingModel booking;

  const MapScreen({super.key, required this.booking});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  late LatLng destinationLatLng;
  LatLng? technicianLatLng;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  StreamSubscription<Position>? positionStream;

  bool isDialogShown = false;
  bool isTrackingStarted = false;

  double currentDistance = 0;
  String? eta;

  final String googleApiKey = "AIzaSyA1v4mq57HE_83ptDaF12R9lWxqGn2xI1k";

  final String _mapStyle = jsonEncode([
    {
      "elementType": "geometry",
      "stylers": [
        {"color": "#f5f5f5"},
      ],
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {"visibility": "off"},
      ],
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#616161"},
      ],
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#f5f5f5"},
      ],
    },
    {
      "featureType": "administrative.land_parcel",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#bdbdbd"},
      ],
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        {"color": "#eeeeee"},
      ],
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#757575"},
      ],
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {"color": "#e5e5e5"},
      ],
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#9e9e9e"},
      ],
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {"color": "#ffffff"},
      ],
    },
    {
      "featureType": "road.arterial",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#757575"},
      ],
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {"color": "#dadada"},
      ],
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#616161"},
      ],
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#9e9e9e"},
      ],
    },
    {
      "featureType": "transit.line",
      "elementType": "geometry",
      "stylers": [
        {"color": "#e5e5e5"},
      ],
    },
    {
      "featureType": "transit.station",
      "elementType": "geometry",
      "stylers": [
        {"color": "#eeeeee"},
      ],
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {"color": "#c9c9c9"},
      ],
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#9e9e9e"},
      ],
    },
  ]);

  @override
  void initState() {
    super.initState();

    if (widget.booking.coordinates != null &&
        widget.booking.coordinates!.length >= 2) {
      destinationLatLng = LatLng(
        widget.booking.coordinates![0],

        widget.booking.coordinates![1],
      );
    } else {
      destinationLatLng = const LatLng(0, 0);
    }

    markers.add(
      Marker(
        markerId: const MarkerId("destination"),
        position: destinationLatLng,
        infoWindow: const InfoWindow(title: "Customer Location"),
      ),
    );

    _loadLocation();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    _routeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final location = await getCurrentLocation();
    technicianLatLng = location;

    markers.add(
      Marker(
        markerId: const MarkerId("technician"),
        position: location,
        infoWindow: const InfoWindow(title: "You"),
      ),
    );

    if (!mounted) return;
    setState(() {});

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
  }

  void _startRide() {
    setState(() {
      isTrackingStarted = true;
    });

    _startTracking();
    _getRoute();
  }

  Future<void> _startTracking() async {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      final newLatLng = LatLng(position.latitude, position.longitude);
      _updateTechnicianLocation(newLatLng);
    });
  }

  void _updateTechnicianLocation(LatLng newLatLng) {
    if (!isTrackingStarted) return;

    double rotation = 0;
    if (technicianLatLng != null) {
      rotation = _calculateBearing(technicianLatLng!, newLatLng);
    }

    technicianLatLng = newLatLng;

    if (!mounted) return;
    setState(() {
      markers.removeWhere((m) => m.markerId.value == "technician");

      markers.add(
        Marker(
          markerId: const MarkerId("technician"),
          position: newLatLng,
          rotation: rotation,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: "You"),
        ),
      );
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
    _calculateDistanceAndETA(newLatLng);
    _throttledRouteUpdate();
  }

  double _calculateBearing(LatLng startPoint, LatLng endPoint) {
    double lat1 = startPoint.latitude * math.pi / 180;
    double lon1 = startPoint.longitude * math.pi / 180;
    double lat2 = endPoint.latitude * math.pi / 180;
    double lon2 = endPoint.longitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  void _calculateDistanceAndETA(LatLng current) {
    _getRoute(); // Trigger real route update which updates ETA
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: destinationLatLng,
              zoom: 14,
            ),
            markers: markers,
            polylines: isTrackingStarted ? polylines : {},
            onMapCreated: (controller) {
              mapController = controller;
              controller.setMapStyle(_mapStyle);
              if (technicianLatLng != null) {
                _fitBounds();
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Consumer<ServiceBoyProvider>(
                builder: (context, provider, child) {
                  final currentBooking = provider.bookings.firstWhere(
                    (b) => b.id == widget.booking.id,
                    orElse: () => widget.booking,
                  );
                  print(currentBooking.status);
                  final bool isReached =
                      currentBooking.status == BookingStatus.reached;
                  final bool isClosed =
                      currentBooking.status == BookingStatus.closed;

                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eta ?? "Calculating...",
                                          style: AppTextStyles.h2.copyWith(
                                            color:
                                                isTrackingStarted
                                                    ? AppColors.error
                                                    : AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          "${(currentDistance / 1000).toStringAsFixed(1)} km away",
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        currentBooking.bookingId,
                                        style: AppTextStyles.labelSmall
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey[200],
                                      child: const Icon(
                                        Iconsax.user,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentBooking.customerName,
                                            style: AppTextStyles.h4,
                                          ),
                                          Text(
                                            currentBooking.serviceName,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          () => _makePhoneCall(
                                            currentBooking.customerPhone,
                                          ),
                                      icon: const Icon(
                                        Iconsax.call,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Icon(
                                      Iconsax.location5,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        currentBooking.location,
                                        style: AppTextStyles.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    text:
                                        isReached
                                            ? "ARRIVED"
                                            : isTrackingStarted
                                            ? "MARK AS ARRIVED"
                                            : isClosed
                                            ? "TRIP ENDED"
                                            : "START TRIP",
                                    isLoading: provider.isReaching,
                                    onPressed:
                                        isReached
                                            ? null
                                            : isClosed
                                            ? null
                                            : isTrackingStarted
                                            ? _markAsArrived
                                            : _startRide,
                                    backgroundColor:
                                        isClosed
                                            ? const Color.fromARGB(
                                              129,
                                              29,
                                              28,
                                              28,
                                            )
                                            : isReached
                                            ? AppColors.primary
                                            : isTrackingStarted
                                            ? AppColors.error
                                            : AppColors.primary,
                                    textColor:
                                        isClosed
                                            ? const Color.fromARGB(
                                              255,
                                              173,
                                              171,
                                              171,
                                            )
                                            : Colors.white,
                                    height: 56,
                                    borderRadius: 16,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReachedDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Reached Destination"),
            content: const Text("Have you reached customer location?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  isDialogShown = false;
                },
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _markAsArrived();
                },
                child: const Text("Yes"),
              ),
            ],
          ),
    );
  }

  void _markAsArrived() async {
    setState(() {
      isTrackingStarted = false;
    });
    // This could also trigger a provider update if needed
    final provider = context.read<ServiceBoyProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await provider.reachedBooking(widget.booking.id);
    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Work reached successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(provider.bookingsError ?? 'Failed to reached work'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _getRoute() async {
    if (technicianLatLng == null) return;

    final result = await LocationService.getDirections(
      technicianLatLng!,
      destinationLatLng,
    );
    if (result != null) {
      setState(() {
        polylineCoordinates = result['points'];
        eta = result['duration'];
        // Use the meters value for distance-based triggers (like reaching destination)
        currentDistance = (result['distance_meters'] as num).toDouble();
      });

      _setPolyline();

      // Check if arrived
      if (currentDistance < 50 && !isDialogShown) {
        isDialogShown = true;
        _showReachedDialog();
      }
    }
  }

  void _setPolyline() {
    polylines.clear();
    polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        color: AppColors.error,
        width: 6,
        points: polylineCoordinates,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Timer? _routeTimer;
  void _throttledRouteUpdate() {
    if (_routeTimer?.isActive ?? false) return;
    _routeTimer = Timer(const Duration(seconds: 10), () {
      _getRoute();
    });
  }

  void _fitBounds() {
    if (mapController == null || technicianLatLng == null) return;
    LatLngBounds bounds;
    if (technicianLatLng!.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          destinationLatLng.latitude - 0.01,
          destinationLatLng.longitude - 0.01,
        ),
        northeast: LatLng(
          technicianLatLng!.latitude + 0.01,
          technicianLatLng!.longitude + 0.01,
        ),
      );
    } else {
      bounds = LatLngBounds(
        southwest: LatLng(
          technicianLatLng!.latitude - 0.01,
          technicianLatLng!.longitude - 0.01,
        ),
        northeast: LatLng(
          destinationLatLng.latitude + 0.01,
          destinationLatLng.longitude + 0.01,
        ),
      );
    }
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}
