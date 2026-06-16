import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'dugc4cfb5';
  static const String uploadPreset = 'driving_school';

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  static Future<String?> uploadFile(XFile file, String folder) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image, folder: folder),
      );
      print('Cloudinary Upload Success: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary Upload Failed: $e');
      return null;
    }
  }
}
