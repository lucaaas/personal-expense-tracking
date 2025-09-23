import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static FirebaseHelper? _instance;
  late FirebaseFirestore _firebase;

  FirebaseHelper._() {
    _firebase = FirebaseFirestore.instance;
  }

  static FirebaseHelper getInstance() {
    _instance ??= FirebaseHelper._();
    return _instance!;
  }

  Future<void> addData(String collection, Map<String, dynamic> data, String id) async {
    await _firebase.collection(collection).doc(id).set(data);
  }
}
