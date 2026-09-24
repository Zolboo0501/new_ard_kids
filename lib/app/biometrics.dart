import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// The biometric the device offers for sign-in. Face wins when a device has
/// both, as on the Security screen and the sign-in button.
enum BiometricKind {
  face(
    name: 'Face ID',
    icon: Icons.face_retouching_natural_rounded,
    loginLabel: 'Face ID-аар нэвтрэх',
    description: 'Царай таньж шууд нэвтрэх',
  ),
  fingerprint(
    name: 'Хурууны хээ',
    icon: Icons.fingerprint_rounded,
    loginLabel: 'Хурууны хээгээр нэвтрэх',
    description: 'Хурууны хээгээ уншуулж шууд нэвтрэх',
  );

  const BiometricKind({
    required this.name,
    required this.icon,
    required this.loginLabel,
    required this.description,
  });

  final String name;
  final IconData icon;
  final String loginLabel;
  final String description;
}

/// Whether "Биометрээр нэвтрэх" is on (Security screen). The sign-in screen
/// offers biometric sign-in only while this is true.
final appBiometricLogin = ValueNotifier<bool>(false);

/// How a biometric prompt ended. Every failure carries the message to show
/// the kid; a cancel shows nothing.
enum BiometricResult {
  success(null),
  canceled(null),
  notEnrolled(
    'Утасныхаа тохиргооноос Face ID эсвэл хурууны хээгээ бүртгүүлнэ үү',
  ),
  lockedOut(
    'Олон удаа буруу уншуулсан тул түр түгжигдлээ. Дараа дахин оролдоно уу',
  ),
  failed('Баталгаажуулалт амжилтгүй боллоо');

  const BiometricResult(this.message);

  final String? message;
}

/// The device's biometric sensor. Tests replace [instance] with a fake; the
/// real one reports no biometrics when the plugin is missing.
abstract class Biometrics {
  static Biometrics instance = _LocalAuthBiometrics();

  /// The enrolled biometric, or null when the device has none (no sensor,
  /// nothing enrolled, or the check failed).
  Future<BiometricKind?> available();

  /// Whether the device has a biometric sensor, enrolled or not. With a
  /// sensor but nothing [available], the kid can still set one up in the
  /// phone's settings.
  Future<bool> hasSensor();

  /// Shows the system prompt with [reason].
  Future<BiometricResult> authenticate(String reason);
}

class _LocalAuthBiometrics implements Biometrics {
  final _auth = LocalAuthentication();

  @override
  Future<BiometricKind?> available() async {
    try {
      if (!await _auth.isDeviceSupported()) return null;
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      // Android reports its sensors as strong/weak rather than by kind.
      return types.isEmpty ? null : BiometricKind.fingerprint;
    } catch (e) {
      debugPrint('Biometrics.available failed: $e');
      return null;
    }
  }

  @override
  Future<bool> hasSensor() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Biometrics.hasSensor failed: $e');
      return false;
    }
  }

  @override
  Future<BiometricResult> authenticate(String reason) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on LocalAuthException catch (e) {
      debugPrint('Biometrics.authenticate failed: $e');
      return switch (e.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout => BiometricResult.canceled,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet => BiometricResult.notEnrolled,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => BiometricResult.lockedOut,
        _ => BiometricResult.failed,
      };
    } catch (e) {
      debugPrint('Biometrics.authenticate failed: $e');
      return BiometricResult.failed;
    }
  }
}

/// Keeps [appBiometricLogin] in secure storage so it survives an app restart.
///
/// Storage errors never reach the UI: a failed read leaves biometric sign-in
/// off and a failed write keeps the choice for this session only.
abstract final class BiometricStore {
  static const _key = 'biometric_login';
  static const _storage = FlutterSecureStorage();

  /// Applies the saved choice to [appBiometricLogin]. Called before `runApp`.
  static Future<void> load() async {
    try {
      appBiometricLogin.value = await _storage.read(key: _key) == 'true';
    } catch (e) {
      debugPrint('BiometricStore.load failed: $e');
    }
  }

  static Future<void> save(bool enabled) async {
    appBiometricLogin.value = enabled;
    try {
      await _storage.write(key: _key, value: '$enabled');
    } catch (e) {
      debugPrint('BiometricStore.save failed: $e');
    }
  }
}
