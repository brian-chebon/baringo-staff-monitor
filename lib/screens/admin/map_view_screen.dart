import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/work_report_model.dart';

class MapViewScreen extends StatefulWidget {
  final WorkReportModel report;

  const MapViewScreen({super.key, required this.report});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _controller;
  LatLng? _reportLocation;

  @override
  void initState() {
    super.initState();
    final geo = widget.report.geoLocation;
    if (geo != null) {
      _reportLocation = LatLng(geo.latitude, geo.longitude);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Location')),
      body: _reportLocation == null
          ? _error('No GPS location was recorded with this report.')
          : GoogleMap(
              onMapCreated: (c) => _controller = c,
              initialCameraPosition: CameraPosition(
                target: _reportLocation!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('reportLocation'),
                  position: _reportLocation!,
                  infoWindow: InfoWindow(
                    title: widget.report.task,
                    snippet: widget.report.location,
                  ),
                ),
              },
            ),
    );
  }

  Widget _error(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

