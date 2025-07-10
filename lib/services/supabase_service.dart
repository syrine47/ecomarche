import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String bucketName = 'syrinebucket';

  /// Upload une image vers Supabase Storage
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Générer un nom unique
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      // Lire les bytes
      final bytes = await imageFile.readAsBytes();

      // Déterminer le type MIME
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      final response = await _client.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      // Vérifier le chemin de retour
      print('📂 Fichier uploadé à : $response');

      // Générer le lien public
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);
      print('✅ URL publique générée : $publicUrl');

      return publicUrl;

    } catch (e) {
      print('❌ Erreur lors de l\'upload de l\'image : $e');
      return null;
    }
  }

  /// Pour le Web : upload depuis bytes
  static Future<String?> uploadImageFromBytes(Uint8List bytes, String fileName) async {
    try {
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

      await _client.storage
          .from(bucketName)
          .uploadBinary(
            uniqueFileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(uniqueFileName);
      print('✅ URL publique (Web) : $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Erreur Web upload : $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String fileName) async {
    try {
      await _client.storage.from(bucketName).remove([fileName]);
      print('✅ Image supprimée : $fileName');
      return true;
    } catch (e) {
      print('❌ Erreur suppression image : $e');
      return false;
    }
  }
}
