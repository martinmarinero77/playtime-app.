import 'package:flutter/material.dart';

// ===================
// PANTALLA DE BIENVENIDA
// Primera pantalla que ve el usuario al abrir la app
// Contiene opciones para Login y Registro
// ===================
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  // Controlador para animaciones (opcional)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializar animaciones - OPCIONAL: Comentar si no quieres animaciones
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500), // Duración de la animación - AJUSTAR según preferencia
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    // Iniciar animación al cargar la pantalla
    _animationController.forward();
  }

  // ===================
  // FUNCIÓN: Navegar a Login
  // AQUÍ AGREGAR: Navegación a la pantalla de login
  // ===================
  void _navigateToLogin() {
    Navigator.pushNamed(context, 'login');  }

  // ===================
  // FUNCIÓN: Navegar a Registro
  // AQUÍ AGREGAR: Navegación a la pantalla de registro
  // ===================
  void _navigateToRegister() {
    Navigator.pushNamed(context, 'registro');
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de la pantalla
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fondo con gradiente - MODIFICAR colores según tu marca
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[600]!, // Color superior - CAMBIAR
              Colors.blue[800]!, // Color medio
              Colors.blue[900]!, // Color inferior - CAMBIAR
            ],
            begin: Alignment.topCenter, // Inicio del gradiente
            end: Alignment.bottomCenter, // Final del gradiente
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation, // Aplicar animación de fade - OPCIONAL
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ===================
                    // SECCIÓN SUPERIOR: Logo y título
                    // ===================
                    Column(
                      children: [
                        SizedBox(height: size.height * 0.02), // Espaciado responsivo
                        
                        // Logo de la app
                        Container(
                          width: 140, // Tamaño del logo - AJUSTAR según diseño
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2), // Fondo semi-transparente
                            shape: BoxShape.circle, // Forma circular
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 20,
                                offset: Offset(0, 10), // Sombra hacia abajo
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '⚽', // Emoji del logo - REEMPLAZAR con Image.asset('assets/logo.png')
                              style: TextStyle(fontSize: 70),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Nombre de la app
                        Text(
                          'PlayTime', // CAMBIAR nombre de tu app
                          style: TextStyle(
                            fontSize: 42, // Tamaño grande para impacto - AJUSTAR
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2, // Espaciado entre letras
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        
                        // Slogan o descripción
                        Text(
                          'Reservá tu cancha en segundos', // CAMBIAR slogan
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18, // Tamaño mediano - AJUSTAR
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                    SizedBox(height: 16),
                    // ===================
                    // SECCIÓN CENTRAL: Características destacadas (OPCIONAL)
                    // ===================
                    Column(
                      children: [
                        _buildFeatureItem(
                          icon: Icons.search,
                          text: 'Buscá canchas disponibles', // CAMBIAR características
                        ),
                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.calendar_today,
                          text: 'Reservá en tiempo real',
                        ),
                        SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.group,
                          text: 'Conectá con otros jugadores',
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // ===================
                    // SECCIÓN INFERIOR: Botones de acción
                    // ===================
                    Column(
                      children: [
                        // BOTÓN PRINCIPAL: Crear Cuenta (Registro)
                        SizedBox(
                          width: double.infinity, // Ocupa todo el ancho
                          height: 56, // Altura del botón - AJUSTAR
                          child: ElevatedButton(
                            onPressed: _navigateToRegister, // Navegar a registro
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 25, 187, 119), // Fondo blanco - CAMBIAR color
                              foregroundColor: Colors.white, // Color del texto - CAMBIAR
                              side: BorderSide(
                                color: Colors.white, // Color del borde - CAMBIAR
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16), // Bordes redondeados
                              ),
                              elevation: 8, // Sombra pronunciada para destacar
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, size: 24), // Ícono de registro
                                SizedBox(width: 12),
                                Text(
                                  'Crear Cuenta', // CAMBIAR texto del botón
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16), // Espaciado entre botones
                        
                        // BOTÓN SECUNDARIO: Iniciar Sesión
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _navigateToLogin, // Navegar a login
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.blue[600], // Fondo blanco - CAMBIAR color
                              foregroundColor: Colors.white, // Color del texto
                              side: BorderSide(
                                color: Colors.white, // Color del borde - CAMBIAR
                                width: 1, // Grosor del borde
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: 24), // Ícono de login
                                SizedBox(width: 12),
                                Text(
                                  'Iniciar Sesión', // CAMBIAR texto del botón
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================
  // WIDGET PERSONALIZADO: Item de característica
  // Muestra un ícono con texto descriptivo
  // Parámetros: icon (ícono), text (texto descriptivo)
  // ===================
  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Fondo semi-transparente
        borderRadius: BorderRadius.circular(12), // Bordes redondeados
        border: Border.all(
          color: Colors.white.withOpacity(0.3), // Borde sutil
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24, // Tamaño del ícono - AJUSTAR
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15, // Tamaño del texto - AJUSTAR
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Limpiar recursos cuando el widget se destruye
  @override
  void dispose() {
    _animationController.dispose(); // Liberar el controlador de animaciones
    super.dispose();
  }
}