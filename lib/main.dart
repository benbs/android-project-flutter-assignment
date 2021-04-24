import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:hello_me/login_screen.dart';
import 'package:hello_me/names_repository.dart';
import 'package:hello_me/saved_screen.dart';
import 'package:hello_me/suggestions_secreen.dart';
import 'package:hello_me/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'suggestions_secreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AuthRepository>(
        create: (_) => AuthRepository.instance()),
    ChangeNotifierProxyProvider<AuthRepository, NamesRepository>(
        create: (_) => NamesRepository(AuthRepository.instance()),
        update: (_, authRepository, namesRepository) {
          namesRepository?.update(authRepository);
          return namesRepository as NamesRepository;
        })
  ], child: App()));
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(
        // Add the 3 lines from here...
        primaryColor: Colors.red,
        accentColor: Colors.teal,
        bottomAppBarColor: Colors.grey,
      ),
      home: SuggestionsScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/saved': (context) => SavedScreen(),
      },
    );
  }


}
