import { after, before, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, getDocs, collection, setDoc } from 'firebase/firestore';

const SUBCOLLECTIONS = ['foodItems', 'dietPlans', 'dietHistory', 'workoutHistory', 'health_metrics'];

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-befit',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(async () => env?.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  // Seed bob's data with rules disabled.
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/bob'), { name: 'Bob', streak: 3 });
    for (const sub of SUBCOLLECTIONS) {
      await setDoc(doc(db, `users/bob/${sub}/x`), { v: 1 });
    }
  });
});

describe('users/{uid}', () => {
  test('owner can read and write their profile doc', async () => {
    const db = env.authenticatedContext('alice').firestore();
    await assertSucceeds(setDoc(doc(db, 'users/alice'), { name: 'Alice' }));
    await assertSucceeds(getDoc(doc(db, 'users/alice')));
    await assertSucceeds(deleteDoc(doc(db, 'users/alice')));
  });

  test("another user's profile doc is denied", async () => {
    const db = env.authenticatedContext('alice').firestore();
    await assertFails(getDoc(doc(db, 'users/bob')));
    await assertFails(setDoc(doc(db, 'users/bob'), { name: 'pwned' }));
    await assertFails(deleteDoc(doc(db, 'users/bob')));
  });

  test('anonymous guest (signed in) can use their own doc', async () => {
    const db = env
      .authenticatedContext('guest1', { firebase: { sign_in_provider: 'anonymous' } })
      .firestore();
    await assertSucceeds(setDoc(doc(db, 'users/guest1'), { name: 'Guest' }));
    await assertFails(getDoc(doc(db, 'users/bob')));
  });

  test('unauthenticated access is denied', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users/bob')));
    await assertFails(setDoc(doc(db, 'users/bob'), { name: 'x' }));
  });

  test('listing the users collection is denied', async () => {
    const db = env.authenticatedContext('alice').firestore();
    await assertFails(getDocs(collection(db, 'users')));
  });
});

describe('users/{uid}/** subcollections', () => {
  for (const sub of SUBCOLLECTIONS) {
    test(`${sub}: owner allowed, other user and anon denied`, async () => {
      const bob = env.authenticatedContext('bob').firestore();
      await assertSucceeds(getDocs(collection(bob, `users/bob/${sub}`)));
      await assertSucceeds(setDoc(doc(bob, `users/bob/${sub}/y`), { v: 2 }));
      await assertSucceeds(deleteDoc(doc(bob, `users/bob/${sub}/y`)));

      const alice = env.authenticatedContext('alice').firestore();
      await assertFails(getDoc(doc(alice, `users/bob/${sub}/x`)));
      await assertFails(getDocs(collection(alice, `users/bob/${sub}`)));
      await assertFails(setDoc(doc(alice, `users/bob/${sub}/z`), { v: 3 }));
      await assertFails(deleteDoc(doc(alice, `users/bob/${sub}/x`)));

      const anon = env.unauthenticatedContext().firestore();
      await assertFails(getDoc(doc(anon, `users/bob/${sub}/x`)));
    });
  }
});

describe('default deny', () => {
  test('top-level collections outside users/ are denied', async () => {
    const db = env.authenticatedContext('alice').firestore();
    await assertFails(getDoc(doc(db, 'admin/config')));
    await assertFails(setDoc(doc(db, 'notifications/n1'), { t: 'x' }));
  });
});
