import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestPermissions() async {
    // Request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission
          .photos, // Or storage depending on OS version logic, but photos is safer generic
    ].request();

    // Check if critical permissions are granted
    // We can be strict or loose here.
    // For now, return true if location is granted as it's the core feature.
    // Camera/Photos can be requested on demand later if denied initially,
    // but we want to ask all upfront as per user request.

    bool locationGranted = statuses[Permission.location]?.isGranted ?? false;
    // bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;

    return locationGranted;
  }

  Future<bool> checkPermissions() async {
    var location = await Permission.location.status;
    return location.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
