import 'package:permission_handler/permission_handler.dart';

/// Helper to request media permissions for attachments (camera / gallery)
class AttachmentsPermissions {
  /// Ensure camera permission is granted
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final req = await Permission.camera.request();
    return req.isGranted;
  }

  /// Ensure gallery/photos permission is granted
  ///
  /// - On Android: use storage permission as a fallback for older devices.
  /// - On iOS: photos permission is used (granted or limited).
  static Future<bool> ensurePhotos() async {
    // First try the photos permission (works for iOS and newer Android)
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted || photosStatus.isLimited) return true;

    // Fallback to storage permission (older Android versions)
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    // Request photos permission
    final photosReq = await Permission.photos.request();
    if (photosReq.isGranted || photosReq.isLimited) return true;

    // If still not granted, request storage permission
    final storageReq = await Permission.storage.request();
    return storageReq.isGranted;
  }
}
