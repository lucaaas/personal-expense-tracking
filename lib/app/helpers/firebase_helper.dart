import 'package:cloud_firestore/cloud_firestore.dart';

abstract mixin class FirebaseHelper {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Future<void> addDataToId(String id, Map<String, dynamic> data) async {
    await _firebase.collection(collection).doc(id).set(data);
  }

  Future<void> addDataToCollection(String collection, Map<String, dynamic> data) async {
    await _firebase.collection(collection).add(data);
  }

  String get collection;
}
