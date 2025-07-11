import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';
import 'login_page.dart';
import 'activos_page.dart';
import 'en_espera_page.dart';
import 'historial_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ActivosPage(),
    EnEsperaPage(),
    HistorialPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      drawer: _CustomDrawer(userName: authProvider.userName),
      appBar: AppBar(
        title: Text(authProvider.userName),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'ACTIVOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'EN ESPERA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'HISTORIAL',
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

// Sidebar personalizado
class _CustomDrawer extends StatelessWidget {
  final String userName;
  const _CustomDrawer({required this.userName});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.10; // 10% of width
    final starSize = size.width * 0.07;
    final fontSize = size.width * 0.045;
    final buttonFontSize = size.width * 0.045;
    final buttonPaddingV = size.height * 0.018;
    final buttonPaddingH = size.width * 0.08;
    final socialIconSize = size.width * 0.10;

    return Drawer(
      child: Container(
        color: const Color(0xFFE5E5E5),
        child: Column(
          children: [
            Container(
              color: const Color(0xFF6DD5FA),
              width: double.infinity,
              padding: EdgeInsets.only(top: size.height * 0.06, bottom: size.height * 0.015),
              child: Column(
                children: [
                  Icon(Icons.account_circle, size: iconSize, color: Colors.black),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    userName.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => Icon(Icons.star, color: Colors.yellow, size: starSize)),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.03),
            _DrawerItem(icon: Icons.security, label: 'SEGURIDAD', onTap: () {}, iconSize: iconSize, fontSize: fontSize),
            _DrawerItem(icon: Icons.help_outline, label: 'AYUDA', onTap: () {}, iconSize: iconSize, fontSize: fontSize),
            _DrawerItem(
              icon: Icons.logout,
              label: 'CERRAR SESIÓN',
              onTap: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
              iconSize: iconSize,
              fontSize: fontSize,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: size.height * 0.01),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: EdgeInsets.symmetric(vertical: buttonPaddingV, horizontal: buttonPaddingH),
                ),
                onPressed: () {},
                child: Text('Modo Domiciliario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: buttonFontSize)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.02, top: size.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(asset: 'assets/images/instagram.png', url: 'https://instagram.com', size: socialIconSize),
                  SizedBox(width: size.width * 0.07),
                  _SocialIcon(asset: 'assets/images/facebook.png', url: 'https://facebook.com', size: socialIconSize),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  const _DrawerItem({required this.icon, required this.label, required this.onTap, required this.iconSize, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: iconSize, color: Colors.black),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize)),
      onTap: onTap,
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;
  final String url;
  final double size;
  const _SocialIcon({required this.asset, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Aquí puedes abrir el enlace
      child: Image.asset(asset, height: size, width: size),
    );
  }
}