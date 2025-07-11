import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Importa Provider y tu AuthProvider
import 'package:provider/provider.dart';
import 'features/auth/controllers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Usar el emulador solo en modo debug
  assert(() {
    // Si quieres mantener el emulador de Auth
    // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    return true;
  }());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const LoginPage(title: 'Flutter Home Page'),
      ),
    );
  }
}
