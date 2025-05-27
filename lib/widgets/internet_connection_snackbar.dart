import 'package:flutter/material.dart';

class InternetConnectionSnackbar {
  static void show(BuildContext context, bool isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isConnected ? 'Conectado a Internet' : 'Sin conexión a Internet',
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}