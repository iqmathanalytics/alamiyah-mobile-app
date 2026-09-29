import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/content_repository.dart';
import '../repositories/firestore_content_repository.dart';
import '../repositories/mock_content_repository.dart';
import 'admin_auth_service.dart';
import 'firebase_config.dart';
import 'storage_service.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  if (FirebaseConfig.isConfigured) {
    return FirestoreContentRepository();
  }
  return MockContentRepository();
});

final adminAuthServiceProvider = Provider<AdminAuthService>((ref) {
  if (FirebaseConfig.isConfigured) {
    return FirebaseAdminAuthService();
  }
  return StubAdminAuthService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  if (FirebaseConfig.isConfigured) {
    return FirebaseStorageService();
  }
  return StubStorageService();
});
