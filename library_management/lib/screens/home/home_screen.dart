import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'admin_screen.dart';
import 'books_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<Widget> get pages => [
    const BooksScreen(),
    const ProfileScreen(),
    widget.role == "gerant" ? const AdminScreen() : const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Management"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Livres",
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              widget.role == "gerant"
                  ? Icons.admin_panel_settings
                  : Icons.settings,
            ),
            label: widget.role == "gerant" ? "Admin" : "Paramètres",
          ),
        ],
      ),
    );
  }
}
