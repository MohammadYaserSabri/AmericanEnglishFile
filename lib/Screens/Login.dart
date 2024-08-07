import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:flutter_application_caht/Screens/Course.dart';
import 'package:flutter_application_caht/Screens/Rejester.dart';

class Login extends StatefulWidget {
  static const String id = "Login";
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  int _emailAttempts = 0;
  int _passwordAttempts = 0;
  bool _blockLogin = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  Color _emailTextColor = Colors.black;
  Color _passwordTextColor = Colors.black;

  @override
  void initState() {
    super.initState();
  }

  void _showAlertDialog(String title, String content, List<Widget> actions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions,
        );
      },
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );
        print("success");

        AppService().user = _auth.currentUser;

        Navigator.pushNamed(context, Course.id);
      } on FirebaseAuthException catch (e) {
        print(e.code);

        switch (e.code) {
          case 'user-not-found':
            _emailTextColor = Colors.red;
            _emailAttempts++;
            if (_emailAttempts >= 2) {
              _showAlertDialog(
                "No such account",
                "No user found for that email.",
                [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Try Again'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Rejester.id);
                    },
                    child: Text('Create an Account'),
                  ),
                ],
              );
              _emailAttempts = 0;
            }
            break;
          case 'wrong-password':
            _passwordAttempts++;
            _passwordTextColor = Colors.red;
            if (_passwordAttempts >= 3) {
              _showAlertDialog(
                "Account Locked",
                "You have entered the wrong password 3 times. Reset your password to regain access.",
                [
                  TextButton(
                    onPressed: () async {
                      // Implement password reset logic

                      Navigator.of(context).pop();

                      await AppService().sendPasswordReset(_email!, context);
                    },
                    child: Text('Reset Password'),
                  ),
                ],
              );
              _passwordAttempts = 0;
            }
            break;

          case "too-many-requests":
            _showAlertDialog(
              "Account Locked",
              "You have entered the wrong password toom many times. Reset your password to regain access.",
              [
                TextButton(
                  onPressed: () async {
                    // Implement password reset logic

                    Navigator.of(context).pop();

                    await AppService().sendPasswordReset(_email!, context);
                  },
                  child: Text('Reset Password'),
                ),
              ],
            );

            break;
          case 'invalid-email':
            _showAlertDialog(
                "Invalid email", "your email is invalid", [Text("ok")]);
            break;
          default:
            _showAlertDialog(
                "Error", "An error occurred. Please try again", [Text("ok")]);
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background rectangle covering the entire page
          Container(
            color: Colors.deepPurple,
            width: double.infinity,
            height: double.infinity,
          ),
          // White rectangle positioned at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'Logo',
                    child: Image(
                      image: AssetImage(''),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(120),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Login Form",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Sign in to Continue",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              autofocus: true,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: _emailTextColor),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: _emailTextColor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                if (!value.endsWith('@gmail.com')) {
                                  return "Email must end with @gmail.com";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _email = value;
                                _emailTextColor = Colors.black;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              maxLength: 16,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle:
                                    TextStyle(color: _passwordTextColor),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: _passwordTextColor),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 8 characters long';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _password = value;
                                _passwordTextColor = Colors.black;
                              },
                            ),
                            SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Material(
                                  elevation: 5.0,
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: MaterialButton(
                                    onPressed: _blockLogin ? null : _login,
                                    hoverColor:
                                        const Color.fromARGB(255, 46, 41, 41),
                                    minWidth: 200.0,
                                    height: 42.0,
                                    child: Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: Colors.deepPurple.shade50,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Password Recovery'),
                                              content: Text(
                                                'We have sent a recovery password to your email.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password ?',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, Rejester.id);
                                      },
                                      child: Text(
                                        'Sign Up !',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
