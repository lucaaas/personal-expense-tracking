import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract mixin class FirebaseHelper {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Future<void> addDataToId(String id, Map<String, dynamic> data, [String? col]) async {
    CollectionReference collection = _getCollection(col ?? this.collection);
    await collection.doc(id).set(data);
  }

  Future<void> addDataToCollection(String collection, Map<String, dynamic> data) async {
    CollectionReference collectionReference = _getCollection(collection);
    await collectionReference.add(data);
  }

  Future<List<Map<String, dynamic>>> getAllSinceDate(DateTime? since, [String? col]) async {
    CollectionReference collection = _getCollection(col ?? this.collection);

    QuerySnapshot snapshot;

    if (since == null) {
      snapshot = await collection.get();
    } else {
      snapshot = await collection.where('updatedAt', isGreaterThan: since.toIso8601String()).get();
    }

    return _snapshotToList(snapshot);
  }

  Future<Map<String, dynamic>> getDocById(String id, [String? col]) async {
    CollectionReference collection = _getCollection(col ?? this.collection);

    DocumentSnapshot snapshot = await collection.doc(id).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getDocsEqualTo(
    String field,
    String value, [
    String? col,
  ]) async {
    CollectionReference collection = _getCollection(col ?? this.collection);

    QuerySnapshot snapshot = await collection.where(field, isEqualTo: value).get();
    return _snapshotToList(snapshot);
  }

  List<Map<String, dynamic>> _snapshotToList(QuerySnapshot snapshot) {
    List<Map<String, dynamic>> data = [];
    for (var doc in snapshot.docs) {
      data.add(doc.data() as Map<String, dynamic>);
    }

    return data;
  }

  CollectionReference<Map<String, dynamic>> _getCollection(String collection) {
    if (_isAuthenticated) {
      return _firebase.collection("users").doc(_userId).collection(collection);
    } else {
      throw Exception('Not authenticated');
    }
  }

  String get collection;

  bool get _isAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }

  String get _userId {
    return FirebaseAuth.instance.currentUser!.uid;
  }
}
