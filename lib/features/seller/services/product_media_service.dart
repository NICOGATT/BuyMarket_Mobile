import 'dart:convert';

import 'package:buymarket_frontend/core/config/api.config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/selected_media.dart';

class ProductMediaService {
  static const String _fileFieldName = 'files';

  Future<List<String>> upload({
    required SelectedMedia media,
    required String token,
    required int order,
    String? productId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/product-media/upload');

    debugPrint('PRODUCT MEDIA UPLOAD productId: ${productId ?? 'pending'}');
    debugPrint('PRODUCT MEDIA UPLOAD file.path: ${media.file.path}');
    debugPrint('PRODUCT MEDIA UPLOAD media.type: ${media.type}');
    debugPrint('PRODUCT MEDIA UPLOAD order: $order');
    debugPrint('PRODUCT MEDIA UPLOAD file field: $_fileFieldName');

    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['ngrok-skip-browser-warning'] = 'true';

    // Backend currently uses FilesInterceptor('files', 10).
    // If the backend changes, update type, productId, mediaIds, or _fileFieldName.
    if (productId != null) {
      request.fields['productId'] = productId;
    }
    request.fields['type'] = media.type; // "image" | "video"
    request.fields['order'] = order.toString();
    debugPrint('PRODUCT MEDIA UPLOAD fields: ${request.fields}');

    request.files.add(
      await http.MultipartFile.fromPath(
        _fileFieldName,
        media.file.path,
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('PRODUCT MEDIA UPLOAD statusCode: ${response.statusCode}');
    debugPrint('PRODUCT MEDIA UPLOAD response.body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'No se pudo subir ${media.file.name}: ${response.body}',
      );
    }

    final mediaIds = _extractMediaIds(response.body);
    debugPrint('PRODUCT MEDIA UPLOAD mediaIds: $mediaIds');

    if (mediaIds.isEmpty) {
      throw Exception(
        'No se pudo obtener mediaIds para ${media.file.name}: ${response.body}',
      );
    }

    return mediaIds;
  }

  List<String> _extractMediaIds(String responseBody) {
    final decoded = jsonDecode(responseBody);
    final ids = <String>[];

    void collect(dynamic value) {
      if (value == null) return;

      if (value is String) {
        if (value.isNotEmpty) ids.add(value);
        return;
      }

      if (value is List) {
        for (final item in value) {
          collect(item);
        }
        return;
      }

      if (value is Map<String, dynamic>) {
        final id = value['id'] ??
            value['_id'] ??
            value['mediaId'] ??
            value['productMediaId'];

        if (id != null) {
          ids.add(id.toString());
          return;
        }

        collect(value['data']);
        collect(value['value']);
        collect(value['media']);
        collect(value['medias']);
        collect(value['files']);
        collect(value['items']);
      }
    }

    collect(decoded);
    return ids.toSet().toList();
  }
}
