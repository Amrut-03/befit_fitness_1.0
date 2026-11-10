import 'package:cloud_firestore/cloud_firestore.dart';

/// Deletes everything a user owns in Firestore.
///
/// Client SDKs can't list subcollections, so every subcollection under
/// `users/{uid}` must be listed in [userSubcollections]. **If you add a new
/// one anywhere in the app, add it here too**, or account deletion will leave
/// it behind (see also `firestore.rules`).
class UserDataRemoteDataSource {
  static const List<String> userSubcollections = [
    'foodItems',
    'dietPlans',
    'dietHistory',
    'workoutHistory',
    'health_metrics',
  ];

  final FirebaseFirestore firestore;

  /// Firestore allows at most 500 writes per batch.
  final int batchSize;

  UserDataRemoteDataSource({required this.firestore, this.batchSize = 400});

  Future<void> deleteAllUserData(String uid) async {
    final userRef = firestore.collection('users').doc(uid);

    for (final name in userSubcollections) {
      await _deleteCollection(userRef.collection(name));
    }

    await userRef.delete();
  }

  Future<void> _deleteCollection(CollectionReference ref) async {
    while (true) {
      // Read from the server so an offline device fails fast with
      // `unavailable` before anything is deleted, rather than queueing
      // deletes against a stale cache.
      final snapshot = await ref
          .limit(batchSize)
          .get(const GetOptions(source: Source.server));

      if (snapshot.docs.isEmpty) return;

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < batchSize) return;
    }
  }
}
