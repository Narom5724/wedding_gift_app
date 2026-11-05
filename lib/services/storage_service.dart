import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static String _bucketName = 'wedding-gallery';

  static void configureBucketName(String bucketName) {
    final normalizedName = bucketName.trim();
    _bucketName = normalizedName.isNotEmpty
        ? normalizedName
        : 'wedding-gallery';
  }

  SupabaseClient get _client => Supabase.instance.client;

  String get bucketName => _bucketName;

  bool get isConfigured {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>> uploadImage({
    required XFile file,
    required String folder,
  }) async {
    if (!isConfigured) {
      throw StateError(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    final safeName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final storagePath = '$folder/$safeName';

    final bytes = await file.readAsBytes().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException('Reading the selected image took too long.');
      },
    );

    try {
      await _client.storage
          .from(bucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException(
                'The upload timed out. Check your Supabase connection and bucket permissions.',
              );
            },
          );
    } on StorageException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('bucket') && message.contains('not found')) {
        throw StateError(
          'Supabase storage bucket "$bucketName" does not exist. Create it in Supabase Storage or set SUPABASE_STORAGE_BUCKET to the correct bucket name.',
        );
      }
      if (message.contains('403') ||
          message.contains('policy') ||
          message.contains('row level security')) {
        throw StateError(
          'Supabase storage policy is blocking uploads. Make the bucket public or allow the app to upload to "$bucketName".',
        );
      }
      rethrow;
    }

    final imageUrl = _client.storage.from(bucketName).getPublicUrl(storagePath);
    return {'imageUrl': imageUrl, 'storagePath': storagePath};
  }

  Future<void> deleteImage(String storagePath) async {
    if (!isConfigured) {
      return;
    }

    try {
      await _client.storage
          .from(bucketName)
          .remove([storagePath])
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException(
                'Delete timed out. Please check your Supabase storage connection.',
              );
            },
          );
    } on StorageException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('bucket') && message.contains('not found')) {
        return;
      }
      rethrow;
    }
  }
}
