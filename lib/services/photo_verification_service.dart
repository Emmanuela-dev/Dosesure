import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PhotoVerificationService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<XFile?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return photo;
    } catch (e) {
      throw Exception('Failed to capture photo: $e');
    }
  }

  Future<String> uploadPhoto(String userId, String medicationId, XFile photo) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${medicationId}.jpg';
      final Reference ref = _storage.ref().child('dose_proofs/$userId/$fileName');
      
      final File file = File(photo.path);
      final UploadTask uploadTask = ref.putFile(file);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }
}
