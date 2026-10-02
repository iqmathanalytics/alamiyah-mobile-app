import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

class DeviceLocationException implements Exception {
  DeviceLocationException(this.message);
  final String message;
}

/// One reading of where the phone is. Gives up after a short wait and falls
/// back to the last reading the phone already has.
Future<({double latitude, double longitude})> readCurrentCoordinates() async {
  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) {
    throw DeviceLocationException(
      'Location is turned off. Turn it on, or choose a city.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openAppSettings();
    throw DeviceLocationException(
      'Location is blocked. Allow it for Alamiyah in settings, or choose a city.',
    );
  }
  if (permission == LocationPermission.denied) {
    throw DeviceLocationException(
      'Location was not allowed. Choose a city instead.',
    );
  }

  final settings = Platform.isAndroid
      ? AndroidSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 12),
          forceLocationManager: true,
        )
      : const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        );

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );
    return (latitude: position.latitude, longitude: position.longitude);
  } on TimeoutException {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      return (latitude: last.latitude, longitude: last.longitude);
    }
    throw DeviceLocationException(
      'Could not find where you are. Try again outdoors, or choose a city.',
    );
  } on LocationServiceDisabledException {
    await Geolocator.openLocationSettings();
    throw DeviceLocationException(
      'Location is turned off. Turn it on, or choose a city.',
    );
  }
}
