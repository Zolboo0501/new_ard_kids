/// Profile details that aren't shared across features (mock data; comes
/// from the API once there is one).
abstract final class ProfileDetails {
  /// Register number, matching `Kid.birthday` (2012.03.14).
  static const register = 'УХ12231418';

  /// Shown with a middle mask until the teen reveals it.
  static final maskedRegister =
      '${register.substring(0, 2)}••••••${register.substring(8)}';

  static const gender = 'Эрэгтэй';
}
