import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../resources/locale_data/cache_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  //To check is user already logged in
  void checkUserStatus() async {

    if (  await CacheHelper.getData(key: 'UserId',) != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              await _auth.signInAnonymously().then((value) async {
               await CacheHelper.setData(key: 'UserId',value:  value.user!.uid);
               await fireStore
                   .collection("Users")
                   .doc(await CacheHelper
                   .getData(
                   key:
                   'UserId'))
                   .set({});
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              });
            },
            child: const Text("Continue As A Guest")),
      ),
    ));
  }
}
