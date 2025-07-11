import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';
import 'login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(title: 'Login'),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(child: Text('¡Bienvenido a la pantalla principal!')),
    );
  }
}