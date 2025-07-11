import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';
import 'main_page.dart'; // Asegúrate de importar tu página principal

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Color de fondo detrás de la imagen
            Positioned.fill(
              child: Container(
                color: Color(0xFF68ABAD),
              ),
            ),
            // Imagen de fondo
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // Contenido principal
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card de login
                    Container(
                      width: MediaQuery.of(context).size.width < 400
                          ? MediaQuery.of(context).size.width * 0.95
                          : 360.0,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width < 400 ? 16.0 : 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Botón Google
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.account_circle, color: Colors.redAccent),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(color: Color(0xFF6DD5FA)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                await authProvider.signInWithGoogle();
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainPage()),
                                );
                              },
                              label: Text('Iniciar con Google'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Botón Apple
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.apple, color: Colors.black),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(color: Color(0xFF6DD5FA)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                // Aquí iría la lógica de Apple Sign-In
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Función Apple aún no implementada')),
                                );
                              },
                              label: Text('Iniciar con Apple'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Botón para login escrito
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6DD5FA),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Login escrito'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _emailController,
                                          decoration: InputDecoration(labelText: 'E-mail'),
                                        ),
                                        TextField(
                                          controller: _passwordController,
                                          decoration: InputDecoration(labelText: 'Contraseña'),
                                          obscureText: true,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final email = _emailController.text.trim();
                                          final password = _passwordController.text.trim();
                                          final exists = await authProvider.login(email, password);
                                          if (!mounted) return;
                                          if (exists) {
                                            Navigator.of(context).pop();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const MainPage()),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Usuario no existe o contraseña incorrecta')),
                                            );
                                          }
                                        },
                                        child: Text('Ingresar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Login escrito'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Logo GT
                    Image.asset(
                      'assets/images/login_logo.png',
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}