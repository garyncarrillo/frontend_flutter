import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import './login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Registrar Usuario")),
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextFormField(
              controller: confirmController,
              decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text == confirmController.text) {
                  String email = emailController.text;
                  String password = passwordController.text;

                  Map<String, dynamic> response = await authService.register(
                    email,
                    password,
                  );

                  if (response['status']) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Las contraseñas no coinciden")));
                }
              },
              child: Text('Registrarse'),
            )
          ],
        ),
      ),
    );
  }
}
