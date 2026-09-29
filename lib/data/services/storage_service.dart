import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

abstract class StorageService {
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  });

  /// Compresses an image then uploads; returns download URL.
  Future<String> uploadCompressedImage({
    required Uint8List bytes,
    required String folder,
    int maxWidth = 1280,
    int quality = 72,
  });

  Future<void> delete(String path);

  Future<String> getDownloadUrl(String path);
}

class FirebaseStorageService implements StorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  @override
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final ref = _storage.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }

  @override
  Future<String> uploadCompressedImage({
    required Uint8List bytes,
    required String folder,
    int maxWidth = 1280,
    int quality = 72,
  }) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Could not decode image.');
    }
    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;
    final jpg = Uint8List.fromList(
      img.encodeJpg(resized, quality: quality),
    );
    final path = '$folder/${_uuid.v4()}.jpg';
    return uploadBytes(path: path, bytes: jpg, contentType: 'image/jpeg');
  }

  @override
  Future<void> delete(String path) async {
    await _storage.ref(path).delete();
  }

  @override
  Future<String> getDownloadUrl(String path) {
    return _storage.ref(path).getDownloadURL();
  }
}

class StubStorageService implements StorageService {
  @override
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<String> uploadCompressedImage({
    required Uint8List bytes,
    required String folder,
    int maxWidth = 1280,
    int quality = 72,
  }) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<void> delete(String path) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    throw UnimplementedError('Configure Firebase first (FIREBASE_SETUP.md).');
  }
}
