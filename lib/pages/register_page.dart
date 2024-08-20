//Packages
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';

//Widgets
import '../utils/colors.dart';
import '../widgets/containers.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
import '../widgets/rounded_image.dart';

//Providers
import '../providers/authentication_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;

  String? _email;
  String? _password;
  String? _name;
  PlatformFile? _profileImage;

  final _registerFormKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void setIsLoading(bool status) {
    setState(() {
      _isLoading = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03,
              vertical: _deviceHeight * 0.02,
            ),
            height: _deviceHeight * 0.98,
            width: _deviceWidth * 0.97,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _profileImageField(),
                SizedBox(
                  height: _deviceHeight * 0.05,
                ),
                _registerForm(),
                SizedBox(
                  height: _deviceHeight * 0.05,
                ),
                _registerButton(),
                SizedBox(
                  height: _deviceHeight * 0.02,
                ),
              ],
            ),
          ),
          Visibility(
              visible: _isLoading,
              child: centerPageLoading(color: colorBgLoading))
        ],
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
          (file) {
            setState(
              () {
                _profileImage = file;
              },
            );
          },
        );
      },
      child: () {
        if (_profileImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            image: File(_profileImage!.path.toString()),
            size: _deviceHeight * 0.15,
          );
        } else {
          return RoundedImageNetwork(
            key: UniqueKey(),
            imagePath: "https://i.pravatar.cc/150?img=65",
            size: _deviceHeight * 0.15,
          );
        }
      }(),
    );
  }

  Widget _registerForm() {
    return SizedBox(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextFormField(
                  onSaved: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                  regEx: r'.{8,}',
                  hintText: "Name",
                  obscureText: false),
            ),
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

  Widget _registerButton() {
    return RoundedButton(
      name: "Register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if (_registerFormKey.currentState!.validate() &&
            _profileImage != null) {
          _registerFormKey.currentState!.save();

          if (_email != null && _password != null) {
            String? uid = await _auth.registerUserUsingEmailAndPassword(
                _email!, _password!, context);
            if (uid != null) {
              setIsLoading(true);
              String? imageURL = await _cloudStorage.saveUserImageToStorage(
                  uid, _profileImage!);
              await _db.createUser(uid, _email!, _name!, imageURL!);
              await _auth.logout(context);
              await _auth.loginUsingEmailAndPassword(
                  _email!, _password!, context);
              setIsLoading(false);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Error registering user."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Email atau password null."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Form tidak valid atau gambar profil belum dipilih."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}
