import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitness_app/features/auth/data/datasources/remote/user_data_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  Future<void> seed(String uid, {int perCollection = 3}) async {
    await firestore.doc('users/$uid').set({'name': uid, 'streak': 4});
    for (final sub in UserDataRemoteDataSource.userSubcollections) {
      for (var i = 0; i < perCollection; i++) {
        await firestore.doc('users/$uid/$sub/doc$i').set({'i': i});
      }
    }
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  test("deletes the user doc and every subcollection, leaving others' data", () async {
    await seed('alice');
    await seed('bob');

    // A small batch size exercises the multi-batch loop.
    await UserDataRemoteDataSource(firestore: firestore, batchSize: 2)
        .deleteAllUserData('alice');

    expect((await firestore.doc('users/alice').get()).exists, isFalse);
    for (final sub in UserDataRemoteDataSource.userSubcollections) {
      final alice = await firestore.collection('users/alice/$sub').get();
      final bob = await firestore.collection('users/bob/$sub').get();
      expect(alice.docs, isEmpty, reason: sub);
      expect(bob.docs, hasLength(3), reason: sub);
    }
    expect((await firestore.doc('users/bob').get()).exists, isTrue);
  });

  test('succeeds when the user has no data', () async {
    await UserDataRemoteDataSource(firestore: firestore)
        .deleteAllUserData('nobody');
  });
}
