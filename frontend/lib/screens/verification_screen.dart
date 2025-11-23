import 'package:flutter/material.dart';
import '../api_service.dart';

class VerificationScreen extends StatefulWidget {
  final String emailOrPhone;

  const VerificationScreen({super.key, required this.emailOrPhone});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de verificación')),
      );
      return;
    }

    // TODO: Implementar verificación del código con ApiService.
    // ApiService apiService = ApiService();
    // try {
    //   await apiService.verifyCode(widget.emailOrPhone, _codeController.text);
    //   // Navegar a la pantalla de login o bienvenida
    //   Navigator.pushReplacementNamed(context, '/');
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    // }

    // Por ahora, simular verificación exitosa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta verificada exitosamente')),
    );
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Se envió un código a ${widget.emailOrPhone}'),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Código de verificación'),
            ),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
