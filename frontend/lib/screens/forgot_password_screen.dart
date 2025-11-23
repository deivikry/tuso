import 'package:flutter/material.dart';
import '../api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _codeSent = false;

  void _sendCode() async {
    if (_emailOrPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu email o teléfono')),
      );
      return;
    }

    // TODO: Implementar envío de código con ApiService.
    // ApiService apiService = ApiService();
    // try {
    //   await apiService.forgotPassword(_emailOrPhoneController.text);
    //   setState(() => _codeSent = true);
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    // }

    // Por ahora, simular envío
    setState(() => _codeSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código enviado')),
    );
  }

  void _resetPassword() async {
    if (_codeController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    // TODO: Implementar reset de contraseña con ApiService.
    // ApiService apiService = ApiService();
    // try {
    //   await apiService.resetPassword(_emailOrPhoneController.text, _codeController.text, _newPasswordController.text);
    //   Navigator.pushReplacementNamed(context, '/');
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    // }

    // Por ahora, simular reset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña cambiada exitosamente')),
    );
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailOrPhoneController,
              decoration: const InputDecoration(labelText: 'Email o Teléfono'),
            ),
            if (!_codeSent)
              ElevatedButton(
                onPressed: _sendCode,
                child: const Text('Enviar Código'),
              ),
            if (_codeSent) ...[
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código de verificación'),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
              ),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Cambiar Contraseña'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
