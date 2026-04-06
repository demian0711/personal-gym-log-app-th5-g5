import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/cloudinary_config.dart';

/// Service upload ảnh lên Cloudinary thông qua HTTP API.
class CloudinaryService {
  Future<String> uploadToCloudinary(File image) async {
    if (kCloudinaryCloudName.isEmpty || kCloudinaryUploadPreset.isEmpty) {
      throw Exception(
        'Cloudinary chưa được cấu hình. Vui lòng set CLOUDINARY_CLOUD_NAME và CLOUDINARY_UPLOAD_PRESET.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$kCloudinaryCloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = kCloudinaryUploadPreset
      ..fields['folder'] = 'progress_photos'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    if (kCloudinaryApiKey.isNotEmpty) {
      request.fields['api_key'] = kCloudinaryApiKey;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload Cloudinary thất bại: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary không trả về secure_url hợp lệ.');
    }

    return secureUrl;
  }
}
