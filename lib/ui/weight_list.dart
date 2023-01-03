import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weight_tracker/resources/locale_data/cache_helper.dart';

class WeightList extends StatefulWidget {
  const WeightList({Key? key}) : super(key: key);

  @override
  State<WeightList> createState() => _WeightListState();
}

class _WeightListState extends State<WeightList> {
  final fireStore = FirebaseFirestore.instance;
  final weightEditController = TextEditingController();
  void dispose() {
    weightEditController.dispose();
    super.dispose();
  }

  int viewCount = 5;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .doc(CacheHelper.getData(key: "UserId"))
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData && snapshot.data?.data() != null) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<MapEntry<String, dynamic>> weights = [];
              weights.addAll(data.entries);
              weights.sort((a, b) {
                return b.key.compareTo(a.key.toLowerCase());
              });
              return weights.isEmpty
                  ? const Center(
                      child: Text("There is no weights yet"),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: List.generate(
                              weights.length < 5 ? weights.length : viewCount,
                              (index) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(weights[index].key),
                                  Text(weights[index].value.toString()),
                                  IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        viewCount = 5;
                                      });

                                      await fireStore
                                          .collection("Users")
                                          .doc(await CacheHelper.getData(
                                              key: 'UserId'))
                                          .update({
                                        weights[index].key: FieldValue.delete()
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      weightEditController.text =
                                          weights[index].value.toString();
                                      showBottomSheet(
                                        context: context,
                                        builder: (context) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                TextField(

                                                  controller:
                                                      weightEditController,

                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: const InputDecoration(
                                                      hintText: "Weight",
                                                      labelText:
                                                          "Update your weight"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    if (weightEditController
                                                        .text.isNotEmpty) {
                                                      await fireStore
                                                          .collection("Users")
                                                          .doc(await CacheHelper
                                                              .getData(
                                                                  key:
                                                                      'UserId'))
                                                          .update({
                                                        weights[index].key:
                                                            weightEditController
                                                                .text
                                                      });

                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text("Update"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (weights.length > viewCount)
                          ElevatedButton(
                              onPressed: () {
                                if (weights.length <= viewCount + 5) {
                                  setState(() {
                                    viewCount = weights.length;
                                  });
                                } else {
                                  setState(() {
                                    viewCount = viewCount + 5;
                                  });
                                }
                              },
                              child: Text("More Items"))
                      ],
                    );
            } else {
              return const Center(
                child: Text("There is no weights yet"),
              );
            }
        }
      },
    );
  }
}
