import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status;
  }

  /// Check and request camera permission
  /// Returns true if granted, false otherwise
  Future<bool> checkAndRequestCameraPermission() async {
    // Check if already granted
    if (await isCameraPermissionGranted()) {
      return true;
    }

    // Request permission
    final status = await requestCameraPermission();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permanently denied
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Open app settings
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
