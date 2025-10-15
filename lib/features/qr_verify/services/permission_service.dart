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
    final status = await Permission.camera.status;

    // If permission is not determined yet (first time), request it
    if (status.isGranted) {
      return true;
    }

    // Request permission - this will show the iOS dialog on first request
    final result = await Permission.camera.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
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
