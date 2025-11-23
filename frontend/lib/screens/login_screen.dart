import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../api_service.dart';
import 'welcome_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _recordarme = false;
  final FocusNode _usuarioFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  void _ingresar() async {
    // Validar campos vacíos
    if (_usuarioController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Integrar con API backend para login con tokens JWT.
    // Actualmente usa base de datos local, pero preparado para backend.
    // Cuando integres el backend, reemplaza la lógica de DatabaseHelper con ApiService.
    // Ejemplo:
    // ApiService apiService = ApiService();
    // try {
    //   Map<String, dynamic> response = await apiService.loginUser(_usuarioController.text, _passwordController.text);
    //   // Guardar token JWT en almacenamiento seguro
    //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen(username: response['username'])));
    // } catch (e) {
    //   // Manejar error
    // }

    // Por ahora, usar base de datos local
    DatabaseHelper dbHelper = DatabaseHelper();
    Map<String, dynamic>? user = await dbHelper.getUser(
      _usuarioController.text,
      _passwordController.text,
    );

    if (user != null) {
      // Login exitoso, navegar a la pantalla de bienvenida
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) =>
              WelcomeScreen(username: _usuarioController.text),
        ),
      );
    } else {
      // Credenciales incorrectas
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _olvideContrasena() {
    // TODO: Implementar pantalla de recuperación de contraseña.
    // Debe permitir ingresar email o teléfono y enviar código de recuperación.
    // Ejemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
    // En ForgotPasswordScreen, usar ApiService.forgotPassword(emailOrPhone);
    // Luego mostrar pantalla para ingresar código y nueva contraseña, usando ApiService.resetPassword.

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B7387),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(
                maxWidth: 800.0,
                minHeight: 600.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.transparent, width: 10.0),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Iniciar Sesion',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0000FF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),
                  Container(
                    width: 726,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _usuarioController,
                      focusNode: _usuarioFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Usuario o Correo Electrónico',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF0000FF),
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF0000FF),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF0000FF),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (_) {
                        // Al presionar "next" en el teclado, mover foco al password
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    width: 726,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF0000FF),
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF0000FF),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF0000FF),
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (_) {
                        // Al presionar "done" en el teclado, hacer login
                        _ingresar();
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _recordarme,
                              onChanged: (value) {
                                setState(() {
                                  _recordarme = value ?? false;
                                });
                              },
                            ),
                            const Text('Recordarme'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _olvideContrasena,
                              child: Text(
                                'Olvide mi contraseña',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: const Color(0xFF1867B8),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Registrate Ahora',
                                  style: TextStyle(
                                    color: const Color(0xFF1867B8),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _ingresar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          textStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          // ignore: deprecated_member_use
                          shadowColor: Colors.black.withOpacity(0.5),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Ingresar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Divider(
                    color: const Color(0xFF0000FF),
                    thickness: 1.0,
                    indent: 20.0,
                    endIndent: 20.0,
                  ),
                  const SizedBox(height: 24.0),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para login con Facebook
                        },
                        icon: const Icon(Icons.facebook, color: Colors.white),
                        label: const Text('Continuar con Facebook'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para login con Google
                        },
                        icon: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.white,
                        ), // Placeholder for Google icon
                        label: const Text('Continuar con Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para login con Microsoft
                        },
                        icon: const Icon(
                          Icons.computer,
                          color: Colors.white,
                        ), // Placeholder for Microsoft icon
                        label: const Text('Continuar con Microsoft'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
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
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _usuarioFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
