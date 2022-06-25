import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:work_os/constants/constant.dart';
import 'package:work_os/screens/resetpass.dart';
import 'package:work_os/screens/signup.dart';
import 'package:work_os/screens/tasks.dart';

import '../services/global_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late final TextEditingController _emailController =
      TextEditingController(text: '');
  late final TextEditingController _passController =
      TextEditingController(text: '');
  bool _obscureText = true;
  final _loginKey = GlobalKey<FormState>();
  final FocusNode _passFocusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();

    super.initState();
  }

  void sumbitLogin() async {
    final isValid = _loginKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim());
         Navigator.canPop(context) ? Navigator.pop(context) : null;
            Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => TasksScreen(),
        ));

      } catch (error) {
        GlobalMethods.showError(context: context, error: error.toString());
        print("Error = $error");
        setState(() {
          isLoading = false;
        });
      }
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        CachedNetworkImage(
          imageUrl:
              "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
          placeholder: (context, url) => Image.asset(
            'assests/images/wallpaper.jpg',
            fit: BoxFit.fill,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: FractionalOffset(_animation.value, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              Text(
                "Login",
                style: TextStyle(
                    fontSize: 30,
                    color: Constant.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "Don't have an account?",
                    style: TextStyle(
                        color: Constant.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const TextSpan(text: '  '),
                TextSpan(
                    text: "Register",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ));
                      },
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ])),
              SizedBox(
                height: size.height * 0.05,
              ),
              Form(
                key: _loginKey,
                child: Column(
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_passFocusNode),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains("@")) {
                          return "Please enter a valid Email address";
                        }
                        return null;
                      },
                      controller: _emailController,
                      style: TextStyle(color: Constant.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: TextStyle(color: Constant.white),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Constant.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Constant.white)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple)),
                        errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      focusNode: _passFocusNode,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: sumbitLogin,
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return "Please enter a valid Password";
                        }
                        return null;
                      },
                      controller: _passController,
                      style: TextStyle(color: Constant.white),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Constant.white,
                          ),
                        ),
                        hintText: "Enter your password",
                        hintStyle: TextStyle(color: Constant.white),
                        labelText: "Password",
                        labelStyle: TextStyle(color: Constant.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Constant.white)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple)),
                        errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResetScreen(),
                          ));
                    },
                    child: Text(
                      "Forget password",
                      style: TextStyle(
                          color: Constant.white,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              const SizedBox(
                height: 35,
              ),
             isLoading?Center(child: Container(
              width: 60,
              height: 60,
              child:CircularProgressIndicator())) : MaterialButton(
                onPressed: sumbitLogin,
                color: Colors.amberAccent,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20,
                            color: Constant.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.login,
                      color: Constant.white,
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
