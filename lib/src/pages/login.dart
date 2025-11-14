import 'package:flutter/material.dart';
import 'package:playtime/src/controllers/user_controller.dart';

// ===================
// PANTALLA DE LOGIN
// Widget principal para inicio de sesión y registro
// ===================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // CONTROLADORES - Manejan el texto ingresado en los campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // ESTADOS DE LA PANTALLA
  bool _isPasswordVisible = false; // Controla si la contraseña es visible o no
  bool _rememberMe = false; // Checkbox para "Recordarme"
  bool _isLoading = false; // Estado de carga durante el login
  
  // Key para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // ===================
  // FUNCIÓN: Manejar Login
  // Se ejecuta cuando el usuario presiona "Iniciar Sesión"
  // AQUÍ AGREGAR: Lógica de autenticación con API/Firebase
  // ===================
  void _handleLogin() async {
    // Validar que los campos sean correctos
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mostrar indicador de carga
      });
      
      final userController = UserController();
      final userCredential = await userController.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      
      setState(() {
        _isLoading = false;
      });

      if (userCredential != null) {
        // AQUÍ AGREGAR: Navegación a home después de login exitoso
        Navigator.pushReplacementNamed(context, 'home');
        print('Login exitoso con: ${_emailController.text}');
      } else {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email o contraseña incorrectos. Intente de nuevo.'), // CAMBIAR mensaje
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // ===================
  // FUNCIÓN: Navegar a Registro
  // AQUÍ AGREGAR: Navegación a la pantalla de registro
void _navigateToRegister() {
    Navigator.pushNamed(context, 'registro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Color de fondo - CAMBIAR para tema oscuro
      body: SafeArea(
        child: SingleChildScrollView( // Permite scroll si el teclado aparece
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // ===================
                // SECCIÓN SUPERIOR: Header con gradiente
                // ===================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[800]!], // Gradiente azul - MODIFICAR colores
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40), // Bordes redondeados inferiores
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [ Padding(
                      padding: EdgeInsets.symmetric(vertical: 10), // Espaciado vertical - AJUSTAR altura
                      child: Center(
                        child: Column(
                          children: [
                            // Logo o ícono de la app
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2), // Fondo semi-transparente
                                shape: BoxShape.circle, // Forma circular
                              ),
                              child: Center(
                                child: Text(
                                  '⚽', // Emoji del logo - CAMBIAR por Image.asset() para logo real
                                  style: TextStyle(fontSize: 50),
                                ),
                              ),
                            ),
                            // Nombre de la app
                            
                            SizedBox(height: 8),
                            // Subtítulo
                            
                          ],
                        ),
                      ),
                    ),
                   Positioned(
                     top: 10,
                     left: 10,
                     child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                     ),
                   ),
                  ],
                ),
                ),
                // ===================
                // SECCIÓN CENTRAL: Formulario de Login
                // ===================
                Expanded(
                  child: ListView(
                    children: [Padding(
                      padding: EdgeInsets.all(24), // Espaciado alrededor del formulario
                      child: Form(
                        key: _formKey, // Key para validación del formulario
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Título de bienvenida
                            Text(
                              '¡Bienvenido!', // CAMBIAR mensaje de bienvenida
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Iniciá sesión para continuar', // Subtítulo
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 40),
                            
                            // CAMPO: Email
                            TextFormField(
                              controller: _emailController, // Controlador del campo
                              keyboardType: TextInputType.emailAddress, // Teclado optimizado para email
                              decoration: InputDecoration(
                                labelText: 'Email', // Etiqueta del campo - CAMBIAR texto
                                hintText: 'tu@email.com', // Placeholder
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.blue[600]), // Ícono
                                filled: true,
                                fillColor: Colors.white, // Fondo blanco
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                  borderSide: BorderSide.none, // Sin borde visible
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2), // Borde azul al enfocar
                                ),
                              ),
                              // Validación del campo email
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresá tu email'; // CAMBIAR mensaje de error
                                }
                                // Validación básica de formato email
                                if (!value.contains('@')) {
                                  return 'Ingresá un email válido';
                                }
                                return null; // null = validación exitosa
                              },
                            ),
                            SizedBox(height: 20),
                            
                            // CAMPO: Contraseña
                            TextFormField(
                              controller: _passwordController, // Controlador del campo
                              obscureText: !_isPasswordVisible, // Ocultar/mostrar contraseña
                              decoration: InputDecoration(
                                labelText: 'Contraseña', // Etiqueta - CAMBIAR texto
                                hintText: '••••••••', // Placeholder
                                prefixIcon: Icon(Icons.lock_outlined, color: Colors.blue[600]), // Ícono de candado
                                // Botón para mostrar/ocultar contraseña
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible; // Toggle visibilidad
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                                ),
                              ),
                              // Validación del campo contraseña
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresá tu contraseña'; // CAMBIAR mensaje
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres'; // MODIFICAR requisitos
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            
                            // FILA: Recordarme y Olvidé contraseña
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Checkbox "Recordarme"
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                      activeColor: Colors.blue[600], // Color cuando está marcado
                                    ),
                                    Text(
                                      'Recordarme', // CAMBIAR texto
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                // Link "Olvidé mi contraseña"
                                GestureDetector(
                                  onTap: () {
                                    // AQUÍ AGREGAR: Navegación a pantalla de recuperación de contraseña
                                    print('Recuperar contraseña');
                                  },
                                  child: Text(
                                    '¿Olvidaste tu contraseña?', // CAMBIAR texto
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            
                            // BOTÓN: Iniciar Sesión
                            SizedBox(
                              width: double.infinity, // Botón ocupa todo el ancho
                              height: 56, // Altura del botón - AJUSTAR según diseño
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin, // Desactivar si está cargando
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600], // Color de fondo - CAMBIAR tema
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                  ),
                                  elevation: 2, // Sombra del botón
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(color: Colors.white) // Indicador de carga
                                    : Text(
                                        'Iniciar Sesión', // Texto del botón - CAMBIAR
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // BOTÓN: Registrarse
                            Padding(
                              padding: const EdgeInsets.fromLTRB(120, 0, 120, 0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56, // Altura del botón - AJUSTAR según diseño
                                child: ElevatedButton(
                                  onPressed: _navigateToRegister, // Navegar a registro // Desactivar si está cargando
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 25, 187, 119), // Fondo blanco - CAMBIAR color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                    ),
                                    elevation: 2, // Sombra del botón
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(color: Colors.white) // Indicador de carga
                                      : Text(
                                          'Crear Cuenta', // Texto del botón - CAMBIAR
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]   
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Limpiar controladores cuando el widget se destruye
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}