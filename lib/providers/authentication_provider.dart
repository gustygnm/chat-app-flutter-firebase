import 'package:chat_app_flutter_firebase/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((userLocal) {
      if (userLocal != null) {
        _databaseService.updateUserLastSeenTime(userLocal.uid);
        _databaseService.getUser(userLocal.uid).then(
              (snapshot) {
            Map<String, dynamic> userData =
            snapshot.data()! as Map<String, dynamic>;
            user = ChatUser.fromJSON(
              {
                "uid": userLocal.uid,
                "name": userData["name"],
                "email": userData["email"],
                "last_active": userData["last_active"],
                "image": userData["image"],
              },
            );
            _navigationService.removeAndNavigateToRoute('/home');
          },
        );
      } else {
        if (_navigationService.getCurrentRoute() != '/login') {
          _navigationService.removeAndNavigateToRoute('/login');
        }
      }
    });
  }

  Future<void> loginUsingEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "Error logging user into Firebase: ${e.message}");
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "An error occurred: ${e.toString()}");
      }
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credentials.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "Error registering user: ${e.message}");
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "An error occurred: ${e.toString()}");
      }
    }
    return null;
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "Error logging out: ${e.toString()}");
      }
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
