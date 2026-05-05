import 'package:flutter/material.dart';

import '../services/location_service.dart';

class ReportLocationScreen extends StatefulWidget {
  const ReportLocationScreen({super.key});

  @override
  State<ReportLocationScreen> createState() => _ReportLocationScreenState();
}

class _ReportLocationScreenState extends State<ReportLocationScreen> {
  final LocationService _locationService = LocationService();
  String? _locationInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      final info = await _locationService.getLocationInfo();
      if (!mounted) return;
      setState(() {
        _locationInfo = 'Latitude: ${position.latitude}\n'
            'Longitude: ${position.longitude}\n'
            'IP: ${info.ip}\n'
            'Country: ${info.country}\n'
            'City: ${info.city}';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Location')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _locationInfo == null
                  ? const Center(child: Text('Location data is not available.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Information:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(_locationInfo!),
                        ],
                      ),
                    ),
    );
  }
}
