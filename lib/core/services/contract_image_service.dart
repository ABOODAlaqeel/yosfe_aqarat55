import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ContractImageService {
  static final ImagePicker _picker = ImagePicker();

  /// التقاط صورة باستخدام الكاميرا أو من المعرض
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // ضغط الصورة قليلاً لتخفيف الحجم
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  /// حفظ الصورة محلياً داخل مسار التطبيق الآمن لعدم حذفها
  static Future<String?> saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final contractsDir = Directory('${directory.path}/contracts');

      if (!await contractsDir.exists()) {
        await contractsDir.create(recursive: true);
      }

      final fileName =
          'contract_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';
      final savedImage = await imageFile.copy('${contractsDir.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  /// حذف الصورة (مفيد في حال حذف المستأجر أو تعديل العقد)
  static Future<bool> deleteImageLocally(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
    return false;
  }
}
