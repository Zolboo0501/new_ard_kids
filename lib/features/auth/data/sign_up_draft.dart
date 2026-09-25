/// A Mongolian register number, split the way `RegisterNumberField` edits
/// it: two letters and eight digits.
class RegisterNumber {
  const RegisterNumber(this.letters, this.digits);

  final List<String> letters;
  final String digits;
}

/// What the kid entered on Бүртгүүлэх, kept in memory so later steps can
/// prefill it (the parent link asks for the same register number).
class SignUpDraft {
  SignUpDraft._();

  // TODO: read it from the signed-in account once there is a backend.
  static RegisterNumber? registerNumber;
}
