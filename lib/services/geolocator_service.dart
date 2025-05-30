import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  static Future<bool> checkPermissions(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!context.mounted) return false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Permisos de ubicación desactivados.'),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          serviceEnabled = false;
          if (!context.mounted) return false;
          showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Permisos de ubicación denegados.'),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
        }
      }
      if (permission == LocationPermission.deniedForever) {
        serviceEnabled = false;
        if (!context.mounted) return false;
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Permisos de ubicación desactivados.'),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
      }
    }

    return serviceEnabled;
  }
}
