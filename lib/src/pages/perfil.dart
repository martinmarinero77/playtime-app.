import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ===================
// PÁGINA: Perfil de Usuario
// Muestra información del usuario y opciones de configuración
// ===================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  // ===================
  // FUNCIÓN: Cerrar sesión
  // ===================
  Future<void> _logout() async {
    // Mostrar diálogo de confirmación
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.orange[700], size: 28),
            SizedBox(width: 12),
            Text('Cerrar Sesión'),
          ],
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
        
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Sesión cerrada exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ===================
  // FUNCIÓN: Ver/Editar perfil
  // AQUÍ AGREGAR: Navegación a página de editar perfil
  // ===================
  void _editProfile() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a editar perfil...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================
  // FUNCIÓN: Ver mis reservas
  // AQUÍ AGREGAR: Navegación a página de reservas
  // ===================
  void _viewReservas() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserReservasPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a mis reservas...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================
  // FUNCIÓN: Configuración
  // AQUÍ AGREGAR: Navegación a página de configuración
  // ===================
  void _openSettings() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a configuración...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================
  // FUNCIÓN: Ver mis equipos
  // AQUÍ AGREGAR: Navegación a página de equipos
  // ===================
  void _viewTeams() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => MyTeamsPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a mis equipos...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================
  // FUNCIÓN: Historial de partidos
  // AQUÍ AGREGAR: Navegación a página de historial
  // ===================
  void _viewHistory() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a historial...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================
  // FUNCIÓN: Ayuda y soporte
  // AQUÍ AGREGAR: Navegación a página de ayuda
  // ===================
  void _openHelp() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegar a ayuda...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===================
  // FUNCIÓN: Acerca de
  // ===================
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SportReserva',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.sports_soccer, color: Colors.white, size: 32),
      ),
      children: [
        SizedBox(height: 16),
        Text(
          'Reservá tu cancha en segundos',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          '© 2024 SportReserva. Todos los derechos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay usuario logueado
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
              SizedBox(height: 24),
              Text(
                'No has iniciado sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Inicia sesión para ver tu perfil',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Obtener datos del usuario
    final displayName = _user.displayName ?? 'Usuario';
    final email = _user.email ?? 'Sin email';
    final photoUrl = _user.photoURL;
    final initials = displayName.isNotEmpty 
        ? displayName[0].toUpperCase() 
        : email[0].toUpperCase();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===================
              // HEADER CON GRADIENTE AZUL
              // ===================
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    
                    // Avatar del usuario
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                            child: photoUrl == null
                                ? Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Botón editar foto
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Nombre del usuario
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    
                    // Email
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Botón editar perfil
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 60),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.edit, size: 20),
                        label: Text('Editar Perfil'),
                        onPressed: _editProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),

              // ===================
              // ESTADÍSTICAS RÁPIDAS
              // ===================
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.event,
                        label: 'Reservas',
                        value: '12',
                        color: Colors.blue[600]!,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.sports_soccer,
                        label: 'Partidos',
                        value: '24',
                        color: Colors.green[600]!,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.group,
                        label: 'Equipos',
                        value: '3',
                        color: Colors.orange[600]!,
                      ),
                    ),
                  ],
                ),
              ),

              // ===================
              // SECCIÓN: MI ACTIVIDAD
              // ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Mi Actividad'),
                    SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.calendar_today,
                      title: 'Mis Reservas',
                      subtitle: 'Ver y gestionar reservas',
                      color: Colors.blue[600]!,
                      onTap: _viewReservas,
                    ),
                    SizedBox(height: 8),
                    
                    _buildMenuItem(
                      icon: Icons.group,
                      title: 'Mis Equipos',
                      subtitle: 'Equipos y jugadores',
                      color: Colors.green[600]!,
                      onTap: _viewTeams,
                    ),
                    SizedBox(height: 8),
                    
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Historial',
                      subtitle: 'Partidos anteriores',
                      color: Colors.purple[600]!,
                      onTap: _viewHistory,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ===================
              // SECCIÓN: CONFIGURACIÓN
              // ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Configuración'),
                    SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Ajustes',
                      subtitle: 'Preferencias de la app',
                      color: Colors.grey[700]!,
                      onTap: _openSettings,
                    ),
                    SizedBox(height: 8),
                    
                    _buildMenuItem(
                      icon: Icons.notifications,
                      title: 'Notificaciones',
                      subtitle: 'Gestionar notificaciones',
                      color: Colors.orange[600]!,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navegar a notificaciones...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    
                    _buildMenuItem(
                      icon: Icons.lock,
                      title: 'Privacidad y Seguridad',
                      subtitle: 'Cambiar contraseña',
                      color: Colors.red[600]!,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navegar a privacidad...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ===================
              // SECCIÓN: SOPORTE
              // ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Soporte'),
                    SizedBox(height: 12),
                    
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Ayuda y Soporte',
                      subtitle: 'FAQs y contacto',
                      color: Colors.blue[600]!,
                      onTap: _openHelp,
                    ),
                    SizedBox(height: 8),
                    
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'Acerca de',
                      subtitle: 'Versión e información',
                      color: Colors.grey[600]!,
                      onTap: _showAbout,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ===================
              // BOTÓN CERRAR SESIÓN
              // ===================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.logout, size: 20),
                    label: Text('Cerrar Sesión'),
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red[200]!, width: 1),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ===================
  // WIDGET: Card de Estadística
  // ===================
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ===================
  // WIDGET: Título de Sección
  // ===================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  // ===================
  // WIDGET: Item de Menú
  // ===================
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}