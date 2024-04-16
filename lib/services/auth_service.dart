import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_url.dart';

class AuthService {
  String apiUrl = ApiUrl.apiUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      Map<String, dynamic> body = {
        "user": {'email': email, 'password': password}
      };

      String jsonBody = jsonEncode(body);
      var response = await http.post(
        Uri.parse('$apiUrl/users/sign_in'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String jwt = responseBody['jwt'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);
        return {'status': true, 'message': "Login exitoso"};
      } else {
        return {'status': false, 'message': "Usuario o clave errada "};
      }
    } catch (e) {
      print(e);
      return {'status': false, 'message': "Error en la conexión: $e"};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      Map<String, dynamic> body = {
        "user": {'email': email, 'password': password}
      };

      String jsonBody = jsonEncode(body);
      var response = await http.post(
        Uri.parse('$apiUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        return {'status': true, 'message': "Registro exitoso"};
      } else {
        return {'status': false, 'message': "Usuario o clave errada "};
      }
    } catch (e) {
      print(e);
      return {'status': false, 'message': "Error en la conexión: $e"};
    }
  }
}
