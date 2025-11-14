// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:playtime/src/controllers/user_controller.dart';
import 'package:playtime/src/models/user_model.dart';

class AppbarPage extends StatefulWidget {
  const AppbarPage({super.key});

  @override
  State<AppbarPage> createState() => _AppbarState();
}

class _AppbarState extends State<AppbarPage> {
  UserModel? _user;
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _userController.currentUser;
    if (currentUser != null) {
      final userData = await _userController.getUserData(currentUser.uid);
      if (mounted) {
        setState(() {
          _user = userData;
        });
      }
    }
  }
  
  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final userController = UserController();
              await userController.signOut();
              if (!mounted) return;
              // Navega a la pantalla de login y elimina todas las rutas anteriores.
              Navigator.pushNamedAndRemoveUntil(
                  context, 'login', (Route<dynamic> route) => false);
            },
            child: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Colors.blue[600]!, Colors.blue[800]!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight, 
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PlayTime',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _user != null && _user!.nombre.isNotEmpty
                          ? '¡Hola, ${_user!.nombre}! ⚽'
                          : '¡Hola! ⚽',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[100],
                        ),
                    ),
                  ],
                ),
                //Avatar con botón de logout
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[400],
                      radius: 20,
                      child: _user != null && _user!.nombre.isNotEmpty
                          ? Text(
                              _user!.nombre[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _handleLogout,
                      icon: Icon(Icons.logout),
                      color: Colors.white,
                      tooltip: 'Cerrar Sesión',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16,),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: null,
                decoration: InputDecoration(
                  hintText: 'Buscar canchas, deportes o complejos...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: Icon(Icons.filter_list, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                  });
                },
              ),
            ),
            SizedBox(height: 16,),
            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[100], size: 16),
                SizedBox(width: 4),
                Text(
                  'San Juan, Argentina',
                  style: TextStyle(
                    color: Colors.blue[100],
                    fontSize: 12,
                  ),
                ),
              ],
            ),        
          ],
        ),
      ),
    );
  }
}