import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../res/assets/image_assets.dart';
import '../../../../res/colors/app_color.dart';

class LocationPickerWidget extends StatefulWidget {
  final void Function(LatLng position, String address)? onLocationPicked;
  final String markerImagePath;

  const LocationPickerWidget({
    super.key,
    this.onLocationPicked,
    this.markerImagePath = ImageAssets.map1, // Default marker image
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late GoogleMapController mapController;
  LatLng _selectedLatLng = const LatLng(
    31.481024,
    74.303474,
  ); // Default: Lahore
  String _address = "Loading...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedLatLng = LatLng(position.latitude, position.longitude);
    });

    _getAddressFromLatLng(_selectedLatLng);
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      String addr =
          '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      setState(() {
        _address = addr;
      });

      if (widget.onLocationPicked != null) {
        widget.onLocationPicked!(latLng, addr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with address
        Container(
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
          height: 120,
          color: AppColor.white4Color,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColor.redColor, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _address,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),

        // Google Map with marker
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: _selectedLatLng,
                  zoom: 14.0,
                ),
                onCameraMove: (position) {
                  _selectedLatLng = position.target;
                },
                onCameraIdle: () {
                  _getAddressFromLatLng(_selectedLatLng);
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
              ),
              Positioned(
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColor.whiteColor,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(widget.markerImagePath),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
