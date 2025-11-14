import 'package:flutter/material.dart';
import 'package:playtime/src/pages/home_page.dart';
import 'package:playtime/src/pages/perfil.dart';
import 'package:playtime/src/pages/user_reservas_page.dart';
import 'package:playtime/src/widget/appbar.dart';

// This widget is now the main navigation shell of the app.
class TapbarPage extends StatefulWidget {
  const TapbarPage({super.key});

  @override
  State<TapbarPage> createState() => _TapbarPageState();
}

class _TapbarPageState extends State<TapbarPage> {
  int _selectedIndex = 0;

  // List of pages to be displayed in the body
  static const List<Widget> _widgetOptions = <Widget>[
    PlayTimeHome(),
    PlaceholderPage(title: 'Buscar'), // Placeholder as requested
    UserReservasPage(),
    PlaceholderPage(title: 'Comunidad'), // Placeholder for Community
    ProfilePage(), // Placeholder for Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  PreferredSizeWidget? _buildAppBar() {
    // No AppBar for "Mis Reservas" page as it has a custom header
    if (_selectedIndex == 2) {
      return null;
    }
    
    if (_selectedIndex == 0) {
      return const PreferredSize(
        preferredSize: Size.fromHeight(200.0),
        child: AppbarPage(),
      );
    } else {
      return AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[500],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Comunidad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // Helper method to get AppBar title based on the selected tab
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Buscar Complejo';
      case 2:
        return 'Mis Reservas';
      case 3:
        return 'Comunidad';
      case 4:
        return 'Perfil';
      default:
        return 'PlayTime';
    }
  }
}

// Simple placeholder widget for undeveloped pages
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Página de $title en construcción',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}