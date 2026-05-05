import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads a report photo and returns its download URL.
  /// Path layout: `report_images/{userId}/{timestamp}.jpg`.
  Future<String> uploadReportImage({
    required String userId,
    required String localPath,
  }) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      throw StateError('Image file not found at $localPath');
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('report_images/$userId/$fileName');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }
}
