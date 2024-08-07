import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_caht/DatabaseHelper.dart';
import 'package:flutter_application_caht/Screens/AppService.dart';
import 'package:flutter_application_caht/Screens/Course.dart';
import 'package:flutter_application_caht/Screens/Login.dart';
import 'package:flutter_application_caht/Screens/UserModel.dart';

class Rejester extends StatefulWidget {
  static const String id = "Rejester";

  @override
  State<Rejester> createState() => _RejesterState();
}

class _RejesterState extends State<Rejester> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  UserModel? userModel;

  User? user;

  String? _name;
  String? _email;
  String? _password;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _SignUp() async {
    if (_formState.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        user = _auth.currentUser;
        AppService().user = user;

        var onlineModel = OnlineModel(
            id: user!.uid, state: false, lastOnlineTime: DateTime.now());

        userModel = UserModel(
          id: user!.uid,
          name: _name!,
          password: _password!,
          email: _email!,
          isBlocked: false,
          image:
              "https://firebasestorage.googleapis.com/v0/b/fir-74e71.appspot.com/o/8380015.jpg?alt=media&token=df1bdaa1-f7c5-4783-8c36-ab7e370f59fa",
          numberOfNewMessages: 0,
          blackList: [BlackListUserModel.from()],
          privateUsersId: [],
        );

        try {
          await FirebaseDatabase.instance
              .ref()
              .child("OnlineUsers")
              .child(user!.uid)
              .set(onlineModel.toMap());
          await _fireStore
              .collection("Users")
              .doc(user!.uid)
              .set(userModel!.toMap());

          await DatabaseHelper()
              .createProfileLocallyToDatabase(_name!, user!.uid);

          Navigator.pushNamed(context, Course.id);
        } catch (e) {
          print("fire store error is $e");
          await _auth.signOut();
        }
      } on FirebaseAuthException catch (e) {
        print(e.code);

        switch (e.code) {
          case 'email-already-in-use':
            _showAlertDialog(
              "email already in use",
              "an account found with this email you have provided . try to go back to logIn page to enter the app",
              [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Try Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Login.id);
                  },
                  child: Text('Log in Page'),
                ),
              ],
            );

            break;
          case 'invalid-email':
            _showAlertDialog(
              "Invalid email",
              "The email you have entered is invalid.",
              [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text('try again'),
                ),
              ],
            );

            break;

          case "network-request-failed":
            _showAlertDialog(
              "Network problem",
              "it seems that you have internet connection problem, please cheak your network and then try again",
              [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('try again'),
                ),
              ],
            );
            break;
          case 'operation-not-allowed':
            _showAlertDialog(
              "operation not allowed",
              "server are currently under maintance please try again later",
              [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Back to home'),
                ),
              ],
            );
            //    message = "The email address is invalid.";
            break;
          case 'weak-password':
            _showAlertDialog(
              "weak password",
              "you have eneterd a weak password. try to enter a powerfull password that at least contains 8 character",
              [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Try Again'),
                ),
              ],
            );
            break;
          default:
          //  message = "An error occurred. Please try again.";
        }
        setState(() {});
      }
    } else {
      print(
          " sorry some fields are still has problem please fix them before continue");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background rectangle covering the entire page
          Container(
            color: const Color.fromARGB(255, 51, 31, 24),
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
                        image: AssetImage('images/LogoLogin.png'),
                      )),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(120),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                            key: _formState,
                            child: Column(
                              children: [
                                Text(
                                  "Registration Form",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Sign up to Continue",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "You must fill this part";
                                    }
                                  },
                                  onChanged: (value) {
                                    _name = value;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "You must fill this part";
                                    }
                                    if (!value.endsWith("@gmail.com")) {
                                      return "your email must ends with @gmail.com";
                                    }
                                  },
                                  onChanged: (value) {
                                    _email = value;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "You password required";
                                    }
                                    if (value!.length < 6) {
                                      return "password is too short";
                                    }
                                  },
                                  onChanged: (value) {
                                    _password = value;
                                  },
                                ),
                                SizedBox(height: 10),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Material(
                                        elevation: 5.0,
                                        color: const Color.fromARGB(
                                            255, 16, 24, 27),
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        child: MaterialButton(
                                          onPressed: () async {
                                            await _SignUp();

                                            //   _auth.createUserWithEmailAndPassword(email: email, password: password)
                                          },
                                          hoverColor: const Color.fromARGB(
                                              255, 46, 41, 41),
                                          height: 42.0,
                                          child: Text(
                                            'Register',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                          ),
                        ],
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
