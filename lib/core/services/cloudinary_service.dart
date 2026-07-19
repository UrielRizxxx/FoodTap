import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance =
      CloudinaryService._();

  static const String _cloudName = 'lvdxa9jb';
  static const String _uploadPreset = 'foodtap_unsigned';

  Future<String> uploadProductImage({
    required File image,
    required String productId,
  }) async {
    return _uploadImage(
      image: image,
      publicId: productId,
      folder: 'foodtap/products',
    );
  }

  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    return _uploadImage(
      image: image,
      publicId: '${userId}_$timestamp',
      folder: 'foodtap/profiles',
    );
  }

  Future<String> _uploadImage({
    required File image,
    required String publicId,
    required String folder,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.fields['upload_preset'] =
        _uploadPreset;

    request.fields['public_id'] =
        publicId;

    request.fields['folder'] =
        folder;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
      ),
    );

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      debugPrint(
        'Error Cloudinary ${response.statusCode}: ${response.body}',
      );

      throw Exception(
        'No fue posible subir la imagen a Cloudinary.',
      );
    }

    final data = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    final secureUrl =
        data['secure_url']?.toString();

    if (secureUrl == null ||
        secureUrl.isEmpty) {
      throw Exception(
        'Cloudinary no devolvió la URL de la imagen.',
      );
    }

    return secureUrl;
  }
}