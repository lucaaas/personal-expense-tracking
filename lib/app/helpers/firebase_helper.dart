import 'package:cloud_firestore/cloud_firestore.dart';

abstract mixin class FirebaseHelper {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Future<void> addDataToId(String id, Map<String, dynamic> data, [String? col]) async {
    String collection = col ?? this.collection;

    await _firebase.collection(collection).doc(id).set(data);
  }

  Future<void> addDataToCollection(String collection, Map<String, dynamic> data) async {
    await _firebase.collection(collection).add(data);
  }

  Future<List<Map<String, dynamic>>> getAllSinceDate(DateTime? since, [String? col]) async {
    String collection = col ?? this.collection;
    QuerySnapshot snapshot;

    if (since == null) {
      snapshot = await _firebase.collection(collection).get();
    } else {
      snapshot = await _firebase
          .collection(collection)
          .where('createdAt', isGreaterThan: since.toIso8601String())
          .get();
    }

    return _snapshotToList(snapshot);
  }

  Future<Map<String, dynamic>> getDocById(String id, [String? col]) async {
    String collection = col ?? this.collection;
    DocumentSnapshot snapshot = await _firebase.collection(collection).doc(id).get();

    return snapshot.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getDocsEqualTo(String field, String value,
      [String? col]) async {
    String collection = col ?? this.collection;
    QuerySnapshot snapshot =
        await _firebase.collection(collection).where(field, isEqualTo: value).get();
    return _snapshotToList(snapshot);
  }

  List<Map<String, dynamic>> _snapshotToList(QuerySnapshot snapshot) {
    List<Map<String, dynamic>> data = [];
    for (var doc in snapshot.docs) {
      data.add(doc.data() as Map<String, dynamic>);
    }

    return data;
  }

  String get collection;
}
