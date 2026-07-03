import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:library_management/screens/books/add_book_screen.dart';
import 'package:library_management/screens/books/manage_books_screen.dart';
import 'package:library_management/screens/home/manage_loans_screen.dart';
import 'package:library_management/screens/home/statistics_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/books/book_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Assure-toi d'avoir configuré Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Bibliothèque',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // On définit la route initiale
      initialRoute: '/login',
      // Déclaration de toutes les routes nommées
      routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(role: 'etudiant'), 
              '/bookDetails': (context) => const BookDetailsScreen(),
              // Nouvelles routes pour le gérant :
              '/addBook': (context) => const AddBookScreen(),
              '/manageBooks': (context) => const ManageBooksScreen(),
              '/manageLoans': (context) => const ManageLoansScreen(),
              '/statistics': (context) => const StatisticsScreen(),
            },
    );
  }
}