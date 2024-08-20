//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Widgets
import '../utils/colors.dart';
import '../widgets/containers.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

//Providers
import '../providers/authentication_provider.dart';

//Services
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  final _loginFormKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  bool _isLoading = false;

  void setIsLoading(bool status) {
    setState(() {
      _isLoading = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
        body: Stack(
      children: [
        SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _pageTitle(),
                SizedBox(
                  height: _deviceHeight * 0.04,
                ),
                _loginForm(),
                SizedBox(
                  height: _deviceHeight * 0.05,
                ),
                _loginButton(),
                SizedBox(
                  height: _deviceHeight * 0.02,
                ),
                _registerAccountLink(),
              ],
            ).padded16()),
        Visibility(
            visible: _isLoading,
            child: centerPageLoading(color: colorBgLoading))
      ],
    ));
  }

  Widget _pageTitle() {
    return SizedBox(
      height: _deviceHeight * 0.10,
      child: const Text(
        'Chatify',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SizedBox(
      height: _deviceHeight * 0.18,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextFormField(
                  onSaved: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  regEx:
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  hintText: "Email",
                  obscureText: false),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: CustomTextFormField(
                  onSaved: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                  regEx: r".{8,}",
                  hintText: "Password",
                  obscureText: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return RoundedButton(
      name: "Login",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_loginFormKey.currentState!.validate()) {
          _loginFormKey.currentState!.save();
          setIsLoading(true);
          await _auth.loginUsingEmailAndPassword(_email!, _password!, context);
          setIsLoading(false);
        }
      },
    );
  }

  Widget _registerAccountLink() {
    return GestureDetector(
      onTap: () => _navigation.navigateToRoute('/register'),
      child: const Text(
        'Don\'t have an account?',
        style: TextStyle(
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
