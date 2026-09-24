import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';

class PermissionHelper {
  /// Request and verify camera permission for document capture
  static Future<bool> requestCameraPermission(BuildContext context) async {
    if (kIsWeb) return true;

    try {
      final status = await Permission.camera.status;

      if (status.isGranted || status.isLimited) {
        return true;
      }

      final result = await Permission.camera.request();
      if (result.isGranted || result.isLimited) {
        return true;
      }

      if (context.mounted && (result.isPermanentlyDenied || result.isRestricted)) {
        await _showPermissionSettingsDialog(
          context: context,
          title: 'Camera Permission Needed',
          description:
              'MediCare+ requires camera access to capture photographs of your degree certificates, medical council license, and clinic documents for official verification.',
          icon: Icons.camera_alt_rounded,
        );
      } else if (context.mounted && result.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera access was denied. Please allow permission to capture documents.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('PermissionHelper camera check error: $e');
      return true; // Graceful fallback
    }
  }

  /// Request and verify gallery/photo permission for document selection
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    if (kIsWeb) return true;

    try {
      PermissionStatus status;

      if (Platform.isIOS) {
        status = await Permission.photos.status;
        if (status.isGranted || status.isLimited) return true;
        status = await Permission.photos.request();
      } else {
        // Android: Check photos first (Android 13+), then storage
        final photoStatus = await Permission.photos.status;
        if (photoStatus.isGranted || photoStatus.isLimited) return true;

        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) return true;

        status = await Permission.photos.request();
        if (status.isGranted || status.isLimited) return true;

        status = await Permission.storage.request();
      }

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (context.mounted && (status.isPermanentlyDenied || status.isRestricted)) {
        await _showPermissionSettingsDialog(
          context: context,
          title: 'Photo Library Permission Needed',
          description:
              'MediCare+ requires photo library access to upload scanned certificate copies, degree proofs, and registration documents from your device gallery.',
          icon: Icons.photo_library_rounded,
        );
      } else if (context.mounted && status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo library access was denied. Please allow permission to attach certificates.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('PermissionHelper gallery check error: $e');
      return true; // Graceful fallback
    }
  }

  /// Clean professional dialog directing user to device App Settings
  static Future<void> _showPermissionSettingsDialog({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
