import 'package:cloud_firestore/cloud_firestore.dart';

/// Base Firestore service — typed helpers for get/set/update/delete/streams.
/// All feature repositories depend on this.
class FirestoreService {
  FirestoreService() : _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ─── Single Document ──────────────────────────────────────────────────────

  /// Fetch a single document. Returns null if it doesn't exist.
  Future<DocumentSnapshot?> getDoc(String path) async {
    final doc = await _db.doc(path).get();
    return doc.exists ? doc : null;
  }

  /// Create or fully replace a document.
  Future<void> setDoc(String path, Map<String, dynamic> data) async {
    await _db.doc(path).set(data);
  }

  /// Merge-update a document (only supplied fields change).
  Future<void> updateDoc(String path, Map<String, dynamic> data) async {
    await _db.doc(path).set(data, SetOptions(merge: true));
  }

  /// Delete a document.
  Future<void> deleteDoc(String path) async {
    await _db.doc(path).delete();
  }

  // ─── Collections ─────────────────────────────────────────────────────────

  /// Add a document to a collection with an auto-generated ID.
  /// Returns the generated document ID.
  Future<String> addDoc(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    final ref = await _db.collection(collectionPath).add(data);
    return ref.id;
  }

  /// Real-time stream of an entire collection's documents.
  Stream<QuerySnapshot> collectionStream(String collectionPath) {
    return _db.collection(collectionPath).snapshots();
  }

  /// Real-time stream of a single document.
  Stream<DocumentSnapshot> documentStream(String path) {
    return _db.doc(path).snapshots();
  }

  // ─── Batch / Transaction ─────────────────────────────────────────────────

  /// Run a Firestore transaction.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) updateFunction,
  ) {
    return _db.runTransaction(updateFunction);
  }

  /// Get a collection reference (for advanced queries).
  CollectionReference collection(String path) => _db.collection(path);

  /// Get a document reference.
  DocumentReference doc(String path) => _db.doc(path);
}
