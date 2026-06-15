enum RechargeCodeStatus { active, expired }

class RechargeCode {
  final String code;
  final double amount;
  final DateTime dateGenerated;
  final RechargeCodeStatus status;

  RechargeCode({
    required this.code,
    required this.amount,
    required this.dateGenerated,
    required this.status,
  });
}