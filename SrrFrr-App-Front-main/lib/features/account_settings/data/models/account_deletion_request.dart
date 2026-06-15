class AccountDeletionRequest {
  final String password;
  final String? reason;
  final bool confirmed;

  AccountDeletionRequest({
    required this.password,
    this.reason,
    required this.confirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      'confirmed': confirmed,
    };
  }
}
