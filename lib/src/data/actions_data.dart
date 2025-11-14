import 'package:flutter/material.dart';

// La lista está definida directamente en código Dart.
// Es instantánea, segura y fácil de leer.
final List<Map<String, dynamic>> quickActions = [
  {
    'icon': Icons.calendar_today,
    'label': 'Reservar Cancha',
    'color': Colors.blue,
  },
  {
    'icon': Icons.group,
    'label': 'Buscar Jugadores',
    'color': Colors.green,
  },
  {
    'icon': Icons.emoji_events,
    'label': 'Mis Torneos',
    'color': Colors.orange,
  },
  {
    'icon': Icons.location_on,
    'label': 'Canchas Cercanas',
    'color': Colors.purple,
  },
];