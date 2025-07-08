import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Usar el emulador solo en modo debug
  assert(() {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    return true;
  }());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _status = '';
  GoogleSignInAccount? _googleUser;

  @override
  void initState() {
    super.initState();
    
    // Configurar Firebase Auth state listener
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        if (user == null) {
          _status = 'No autenticado';
        } else {
          _status = 'Autenticado: ${user.email ?? user.displayName ?? 'Usuario'}';
        }
      });
    });

    // Configurar Google Sign-In
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId: '172815875090-6onq8nhplltqne5la6l31clj2p8so356.apps.googleusercontent.com',
      );

      // Escuchar eventos de autenticación
      signIn.authenticationEvents.listen((GoogleSignInAuthenticationEvent event) {
        setState(() {
          _googleUser = switch (event) {
            GoogleSignInAuthenticationEventSignIn() => event.user,
            GoogleSignInAuthenticationEventSignOut() => null,
          };
        });
      });

      // Intentar autenticación ligera
      signIn.attemptLightweightAuthentication();
    } catch (e) {
      setState(() {
        _status = 'Error inicializando Google Sign-In: $e';
      });
    }
  }

  Future<void> _register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        _status = 'Registro exitoso';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _status = 'La contraseña es muy débil.';
        } else if (e.code == 'email-already-in-use') {
          _status = 'El correo ya está en uso.';
        } else {
          _status = e.message ?? 'Error desconocido';
        }
      });
    } catch (e) {
      setState(() {
        _status = e.toString();
      });
    }
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        _status = 'Login exitoso';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _status = 'No existe usuario para ese correo.';
        } else if (e.code == 'wrong-password') {
          _status = 'Contraseña incorrecta.';
        } else {
          _status = e.message ?? 'Error desconocido';
        }
      });
    } catch (e) {
      setState(() {
        _status = e.toString();
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _status = 'Iniciando Google Sign-In...';
      });

      // Verificar si la plataforma soporta authenticate
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        setState(() {
          _status = 'Esta plataforma no soporta autenticación con Google';
        });
        return;
      }

      // Autenticar con Google
      await GoogleSignIn.instance.authenticate();

      // El usuario autenticado estará disponible a través del listener de eventos
      // Esperar un momento para que se actualice el estado
      await Future.delayed(Duration(milliseconds: 500));

      if (_googleUser == null) {
        setState(() {
          _status = 'Login cancelado o falló';
        });
        return;
      }

      // Obtener headers de autorización para Firebase
      final Map<String, String>? headers = 
          await _googleUser!.authorizationClient.authorizationHeaders(['email', 'profile']);

      if (headers == null) {
        setState(() {
          _status = 'No se pudo obtener autorización';
        });
        return;
      }

      // Para Firebase Auth, necesitamos obtener el ID token directamente
      // Esto es una implementación temporal - en una app real necesitarías
      // configurar OAuth correctamente
      setState(() {
        _status = 'Google Sign-In exitoso: ${_googleUser!.displayName ?? _googleUser!.email}';
      });

    } on GoogleSignInException catch (e) {
      setState(() {
        _status = 'Error de Google Sign-In: ${e.description}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error en Google Sign-In: $e';
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.disconnect();
    setState(() {
      _status = 'Sesión cerrada';
      _googleUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Registrar'),
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: const Icon(Icons.account_circle),
              label: const Text('Login con Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Cerrar Sesión'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
