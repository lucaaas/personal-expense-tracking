import 'package:cloud_firestore/cloud_firestore.dart';

abstract mixin class FirebaseHelper {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  
  Future<void> addData(String id, Map<String, dynamic> data) async {
    await _firebase.collection(collection).doc(id).set(data);
  }

  String get collection;
}
