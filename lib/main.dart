import 'package:chat_app_flutter_firebase/utils/colors.dart';
import 'package:flutter/material.dart';

//Packages
import 'package:provider/provider.dart';

//Services
import './services/navigation_service.dart';

//Providers
import './providers/authentication_provider.dart';

//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';

void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(
          const MainApp(),
        );
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext context) {
            return AuthenticationProvider();
          },
        )
      ],
      child: MaterialApp(
        title: 'Chatify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: colorGreyCircleAppBar,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: colorGreyCircleAppBar,
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext context) => const LoginPage(),
          '/register': (BuildContext context) => const RegisterPage(),
          '/home': (BuildContext context) => const HomePage(),
        },
      ),
    );
  }
}
