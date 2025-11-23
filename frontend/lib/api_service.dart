import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para manejar las llamadas a la API backend (Node.js con Postman).
/// Este archivo contiene métodos preparados para integrarse con el backend.
/// Los métodos están comentados para que el compañero de backend sepa dónde editar.
///
/// Instrucciones para el compañero de backend:
/// - Reemplaza las URLs con las de tu servidor Node.js.
/// - Implementa la lógica de tokens JWT para autenticación.
/// - Asegúrate de que el backend maneje códigos de verificación por email/SMS.
/// - Usa Postman para probar los endpoints antes de integrar.
///
/// URLs de ejemplo (reemplaza con las reales):
/// - Base URL: 'https://tu-backend.herokuapp.com/api'
/// - Endpoint de registro: '/register'
/// - Endpoint de login: '/login'
/// - Endpoint de verificación: '/verify'
/// - Endpoint de recuperación: '/forgot-password'

class ApiService {
  static const String baseUrl = 'https://tu-backend.herokuapp.com/api'; // TODO: Reemplaza con la URL real del backend

  /// Método para registrar un usuario.
  /// Envía los datos al backend y espera un código de verificación.
  /// TODO: Implementar envío de código de verificación por email o SMS.
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // TODO: El backend debe enviar un código de verificación al email o teléfono.
        // Aquí se puede manejar la respuesta, por ejemplo, mostrar un campo para ingresar el código.
        return jsonDecode(response.body);
      } else {
        throw Exception('Error en el registro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Método para verificar el código de registro.
  /// TODO: Implementar verificación del código enviado por email o SMS.
  Future<Map<String, dynamic>> verifyCode(String emailOrPhone, String code) async {
    final url = Uri.parse('$baseUrl/verify');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrPhone': emailOrPhone, 'code': code}),
      );

      if (response.statusCode == 200) {
        // TODO: El backend debe confirmar la cuenta y devolver un token JWT.
        return jsonDecode(response.body);
      } else {
        throw Exception('Código inválido: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Método para iniciar sesión.
  /// TODO: Implementar autenticación con token JWT.
  Future<Map<String, dynamic>> loginUser(String usernameOrEmail, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usernameOrEmail': usernameOrEmail, 'password': password}),
      );

      if (response.statusCode == 200) {
        // TODO: El backend debe devolver un token JWT para mantener la sesión.
        return jsonDecode(response.body);
      } else {
        throw Exception('Credenciales incorrectas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Método para recuperar contraseña.
  /// Envía un código de recuperación por email o SMS.
  /// TODO: Implementar envío de código por email o teléfono.
  Future<Map<String, dynamic>> forgotPassword(String emailOrPhone) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrPhone': emailOrPhone}),
      );

      if (response.statusCode == 200) {
        // TODO: El backend debe enviar un código de recuperación.
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al enviar código: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Método para verificar el código de recuperación y cambiar la contraseña.
  /// TODO: Implementar cambio de contraseña con código de verificación.
  Future<Map<String, dynamic>> resetPassword(String emailOrPhone, String code, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cambiar contraseña: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Método para enviar SMS (para registro con teléfono).
  /// TODO: Implementar integración con servicio de SMS (ej. Twilio).
  Future<Map<String, dynamic>> sendSms(String phone, String message) async {
    final url = Uri.parse('$baseUrl/send-sms');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al enviar SMS: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
