import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weight_tracker/ui/login_screen.dart';
import 'package:weight_tracker/ui/weight_list.dart';

import '../resources/locale_data/cache_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fireStore = FirebaseFirestore.instance;
  final weightController = TextEditingController();
  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xf4398c9a),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
            ),
            TextField(
              showCursor: false,
              controller: weightController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              autofocus: false,
              decoration: const InputDecoration(
                  hintText: "Weight", labelText: "Enter your weight"),
            ),
            ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  if (weightController.text.isNotEmpty) {
                    await fireStore
                        .collection("Users")
                        .doc(await CacheHelper.getData(key: 'UserId'))
                        .update({
                      DateFormat('yyyy-MM-DD H:mm')
                          .format(DateTime.now())
                          .toString(): weightController.text
                    });
                    weightController.clear();
                  }
                },
                child: const Text("Add")),
            ElevatedButton(
                onPressed: () async {
                  await CacheHelper.remove(key: "UserId");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: const Text("log out")),
            const Expanded(child: WeightList())
          ],
        ),
      ),
    ));
  }
}
