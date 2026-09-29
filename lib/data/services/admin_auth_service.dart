import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import '../repositories/firestore_content_repository.dart';

/// Admin authentication via Firebase Auth + `admins` profile docs.
abstract class AdminAuthService {
  Future<AdminSession?> currentSession();

  Future<AdminSession> signInWithEmail({
    required String email,
    required String password,
  });

  /// First-run bootstrap: create Auth user + owner profile when none exist.
  Future<AdminSession> bootstrapOwner({
    required String name,
    required String email,
    required String password,
  });

  /// Register when an invite exists for this email.
  Future<AdminSession> registerFromInvite({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<AdminSession?> authStateChanges();

  Future<AdminUser?> fetchAdminProfile(String uid);

  Future<List<AdminUser>> listAdmins();

  Future<void> inviteAdmin({
    required String email,
    required String name,
    required AdminRole role,
  });

  Future<void> setAdminActive(String adminId, bool isActive);
}

class AdminSession {
  const AdminSession({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.profile,
  });

  final String uid;
  final String email;
  final String? displayName;
  final AdminUser profile;
}

class FirebaseAdminAuthService implements AdminAuthService {
  FirebaseAdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _admins =>
      _db.collection('admins');
  CollectionReference<Map<String, dynamic>> get _invites =>
      _db.collection('admin_invites');

  Future<AdminUser> _requireActiveProfile(User user) async {
    final profile = await fetchAdminProfile(user.uid);
    if (profile == null) {
      await _auth.signOut();
      throw StateError(
        'No admin profile for this account. Ask an owner to invite you.',
      );
    }
    if (!profile.isActive) {
      await _auth.signOut();
      throw StateError('This admin account has been deactivated.');
    }
    return profile;
  }

  AdminSession _session(User user, AdminUser profile) {
    return AdminSession(
      uid: user.uid,
      email: user.email ?? profile.email,
      displayName: profile.name,
      profile: profile,
    );
  }

  @override
  Future<AdminSession?> currentSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final profile = await fetchAdminProfile(user.uid);
    if (profile == null || !profile.isActive) return null;
    return _session(user, profile);
  }

  @override
  Future<AdminSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    final profile = await _requireActiveProfile(user);
    return _session(user, profile);
  }

  @override
  Future<AdminSession> bootstrapOwner({
    required String name,
    required String email,
    required String password,
  }) async {
    // Public meta doc — avoids listing /admins before the user is signed in.
    final metaRef = _db.collection('meta').doc('app');
    final meta = await metaRef.get();
    if (meta.exists && meta.data()?['hasOwner'] == true) {
      throw StateError('An owner already exists. Sign in instead.');
    }

    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Resume if Auth user was created on a previous failed attempt.
      if (e.code == 'email-already-in-use') {
        cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } else {
        rethrow;
      }
    }

    final user = cred.user!;
    await user.updateDisplayName(name.trim());

    final existingProfile = await fetchAdminProfile(user.uid);
    if (existingProfile != null) {
      if (!meta.exists) {
        await metaRef.set({
          'hasOwner': true,
          'ownerUid': user.uid,
        });
      }
      return _session(user, existingProfile);
    }

    final profile = AdminUser(
      id: user.uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: AdminRole.owner,
      isActive: true,
      createdAt: DateTime.now().toUtc(),
    );
    await _admins.doc(user.uid).set(profile.toJson());
    await metaRef.set({
      'hasOwner': true,
      'ownerUid': user.uid,
    });

    // Seed categories now that we have admin write access.
    try {
      await FirestoreContentRepository(firestore: _db)
          .seedDefaultCategoriesIfEmpty();
    } catch (_) {
      // Non-fatal — owner can retry from dashboard later.
    }

    return _session(user, profile);
  }

  @override
  Future<AdminSession> registerFromInvite({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final inviteSnap = await _invites.doc(normalized).get();
    if (!inviteSnap.exists) {
      throw StateError('No invite found for this email.');
    }
    final invite = inviteSnap.data()!;
    if (invite['claimed'] == true) {
      throw StateError('This invite was already used.');
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: normalized,
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());

    final role = AdminRole.values.firstWhere(
      (r) => r.name == invite['role'],
      orElse: () => AdminRole.contributor,
    );
    final profile = AdminUser(
      id: user.uid,
      name: name.trim(),
      email: normalized,
      role: role,
      isActive: true,
      createdAt: DateTime.now().toUtc(),
    );
    await _admins.doc(user.uid).set(profile.toJson());
    await _invites.doc(normalized).update({
      'claimed': true,
      'claimedBy': user.uid,
      'claimedAt': DateTime.now().toUtc().toIso8601String(),
    });
    return _session(user, profile);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<AdminSession?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final profile = await fetchAdminProfile(user.uid);
      if (profile == null || !profile.isActive) return null;
      return _session(user, profile);
    });
  }

  @override
  Future<AdminUser?> fetchAdminProfile(String uid) async {
    final doc = await _admins.doc(uid).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return AdminUser.fromJson(data);
  }

  @override
  Future<List<AdminUser>> listAdmins() async {
    final snap = await _admins.get();
    final admins = snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      final created = data['createdAt'];
      if (created is Timestamp) {
        data['createdAt'] = created.toDate().toIso8601String();
      }
      return AdminUser.fromJson(data);
    }).toList();
    admins.sort((a, b) {
      final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aAt.compareTo(bAt);
    });
    return admins;
  }

  @override
  Future<void> inviteAdmin({
    required String email,
    required String name,
    required AdminRole role,
  }) async {
    final normalized = email.trim().toLowerCase();
    await _invites.doc(normalized).set({
      'email': normalized,
      'name': name.trim(),
      'role': role.name,
      'claimed': false,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> setAdminActive(String adminId, bool isActive) async {
    await _admins.doc(adminId).update({'isActive': isActive});
  }
}

/// Used when Firebase is not configured yet.
class StubAdminAuthService implements AdminAuthService {
  @override
  Future<AdminSession?> currentSession() async => null;

  @override
  Future<AdminSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<AdminSession> bootstrapOwner({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<AdminSession> registerFromInvite({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<AdminSession?> authStateChanges() => Stream.value(null);

  @override
  Future<AdminUser?> fetchAdminProfile(String uid) async => null;

  @override
  Future<List<AdminUser>> listAdmins() async => [];

  @override
  Future<void> inviteAdmin({
    required String email,
    required String name,
    required AdminRole role,
  }) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<void> setAdminActive(String adminId, bool isActive) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }
}
