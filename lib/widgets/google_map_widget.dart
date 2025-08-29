import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../res/colors/app_color.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController mapController;

  // Initial location: 47 W 13th St, New York (Lat: 40.735657, Lng: -73.996167)
  static const LatLng initialLocation = LatLng(40.735657, -73.996167);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390, // Width: 390px
      height: 188, // Height: 188px
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Radius: 10px
        border: Border.all(color: AppColor.greyColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: initialLocation,
            zoom: 15, // Adjust zoom level as needed
          ),
          markers: {
            const Marker(
              markerId: MarkerId('location'),
              position: initialLocation,
              infoWindow: InfoWindow(title: '47 W 13th St, New York'),
            ),
          },
          myLocationEnabled: true, // Optional: Show user location
          myLocationButtonEnabled: true, // Optional: Show location button
        ),
      ),
    );
  }
}