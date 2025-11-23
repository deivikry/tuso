import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database_helper.dart';
import '../api_service.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _usarTelefono = false;
  bool _aceptoPoliticas = false;
  final FocusNode _usuarioFocusNode = FocusNode();
  final FocusNode _correoFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  void _registrarse() async {
    // Validar campos vacíos
    if (_usuarioController.text.isEmpty ||
        (_usarTelefono ? _telefonoController.text.isEmpty : _correoController.text.isEmpty) ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar aceptación de políticas
    if (!_aceptoPoliticas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar las políticas de privacidad'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Integrar con API backend para registro con verificación por email/SMS
    // Actualmente usa base de datos local, pero preparado para backend.
    // Cuando integres el backend, reemplaza la lógica de DatabaseHelper con ApiService.
    // Ejemplo:
    // ApiService apiService = ApiService();
    // Map<String, dynamic> userData = {
    //   'username': _usuarioController.text,
    //   'email': _usarTelefono ? null : _correoController.text,
    //   'phone': _usarTelefono ? _telefonoController.text : null,
    //   'password': _passwordController.text,
    // };
    // try {
    //   await apiService.registerUser(userData);
    //   // Mostrar pantalla de verificación de código
    //   // Navigator.push(context, MaterialPageRoute(builder: (context) => VerificationScreen(emailOrPhone: _usarTelefono ? _telefonoController.text : _correoController.text)));
    // } catch (e) {
    //   // Manejar error
    // }

    // Por ahora, usar base de datos local
    DatabaseHelper dbHelper = DatabaseHelper();
    Map<String, dynamic> user = {
      'username': _usuarioController.text,
      'email': _usarTelefono ? null : _correoController.text,
      'phone': _usarTelefono ? _telefonoController.text : null,
      'password': _passwordController.text,
    };

    try {
      await dbHelper.insertUser(user);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso para ${_usuarioController.text}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // Limpiar campos después del registro exitoso
      _usuarioController.clear();
      _correoController.clear();
      _telefonoController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _aceptoPoliticas = false;
      });
      // Navegar a la pantalla de verificación después del registro exitoso
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            emailOrPhone: _usarTelefono ? _telefonoController.text : _correoController.text,
          ),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar usuario. El usuario ya existe.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _abrirPoliticas() async {
    const url = 'https://www.example.com/politicas-privacidad'; // Reemplaza con una URL real
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B7387),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
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
              //
             // decoration: BottomNavigationBarItem(icon: icon)

              //
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Registrarse',
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
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Usuario',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000Ff), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_usarTelefono ? _telefonoFocusNode : _correoFocusNode);
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (!_usarTelefono)
                    Container(
                      width: 726,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _correoController,
                        focusNode: _correoFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Correo Electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.all(16.0),
                        ),
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                      ),
                    ),
                  if (_usarTelefono)
                    Container(
                      width: 726,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _telefonoController,
                        focusNode: _telefonoFocusNode,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Número de Celular',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.all(16.0),
                        ),
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Checkbox(
                        value: _usarTelefono,
                        onChanged: (value) {
                          setState(() {
                            _usarTelefono = value ?? false;
                            if (_usarTelefono) {
                              _correoController.clear();
                            } else {
                              _telefonoController.clear();
                            }
                          });
                        },
                      ),
                      const Text('Usar teléfono en vez de email'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
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
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
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
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Confirmar Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFF0000FF), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (_) {
                        _registrarse();
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Checkbox(
                        value: _aceptoPoliticas,
                        onChanged: (value) {
                          setState(() {
                            _aceptoPoliticas = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'He leído y acepto las ',
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'políticas de privacidad y datos.',
                                style: const TextStyle(
                                  color: Color(0xFF1867B8),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _abrirPoliticas,
                              ),
                            ],
                          ),
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
                        onPressed: _registrarse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          textStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          side: const BorderSide(color: Colors.white, width: 2.0),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ),
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
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usuarioFocusNode.dispose();
    _correoFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
