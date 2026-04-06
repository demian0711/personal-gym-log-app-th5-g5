import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/cloudinary_config.dart';
import '../../../../services/local_storage_service.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;
  final LocalStorageService _storage;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    LocalStorageService? storage,
  }) : _storage = storage ?? LocalStorageService();

  Future<String> uploadImageBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final savedCloudName = (await _storage.getCloudinaryCloudName())?.trim();
    final savedUploadPreset = (await _storage.getCloudinaryUploadPreset())
        ?.trim();

    final effectiveCloudName = (savedCloudName?.isNotEmpty ?? false)
        ? savedCloudName!
        : (cloudName.trim().isNotEmpty
              ? cloudName.trim()
              : CloudinaryConfig.cloudName.trim());

    final effectiveUploadPreset = (savedUploadPreset?.isNotEmpty ?? false)
        ? savedUploadPreset!
        : (uploadPreset.trim().isNotEmpty
              ? uploadPreset.trim()
              : CloudinaryConfig.uploadPreset.trim());

    if (effectiveCloudName.isEmpty || effectiveUploadPreset.isEmpty) {
      throw Exception(
        'Cloudinary chưa được cấu hình. Hãy cập nhật cloudName/uploadPreset.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$effectiveCloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = effectiveUploadPreset
      ..fields['folder'] = CloudinaryConfig.assetFolder
      ..fields['asset_folder'] = CloudinaryConfig.assetFolder
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upload Cloudinary thất bại: ${response.body} '
        '(cloudName=$effectiveCloudName, uploadPreset=$effectiveUploadPreset)',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = body['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary không trả về URL hợp lệ.');
    }

    return secureUrl;
  }
}
