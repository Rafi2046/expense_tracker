import 'dart:math';

class CalculatorUtils {
  static Map<String, double> calculateEmi({
    required double amount,
    required double rate,
    required double years,
  }) {
    if (amount <= 0 || rate < 0 || years <= 0) {
      return {'emi': 0, 'interest': 0, 'payment': 0};
    }

    final double r = rate / 12 / 100;
    final double n = years * 12;

    if (r == 0) {
      if (n == 0) return {'emi': 0, 'interest': 0, 'payment': 0};
      final emi = amount / n;
      return {'emi': emi, 'interest': 0, 'payment': amount};
    }

    final double emi = (amount * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    final double totalPayment = emi * n;
    final double totalInterest = totalPayment - amount;

    return {
      'emi': emi,
      'interest': totalInterest,
      'payment': totalPayment,
    };
  }

  static Map<String, double> calculateInterest({
    required double principal,
    required double rate,
    required double periodValue,
    required String periodUnit,
    required bool isCompound,
    required String frequency,
  }) {
    if (principal <= 0 || rate < 0 || periodValue <= 0) {
      return {'interest': 0, 'maturity': 0, 'principal': 0};
    }

    double years = periodValue;
    switch (periodUnit) {
      case 'Day':
        years = periodValue / 365;
        break;
      case 'Week':
        years = periodValue / 52;
        break;
      case 'Month':
        years = periodValue / 12;
        break;
      case 'Quarter':
        years = periodValue / 4;
        break;
      case 'Year':
      default:
        years = periodValue;
        break;
    }

    if (!isCompound) {
      final double interest = (principal * rate * years) / 100;
      final double maturity = principal + interest;
      return {
        'interest': interest,
        'maturity': maturity,
        'principal': principal,
      };
    } else {
      double n = 1;
      switch (frequency) {
        case 'Monthly':
          n = 12;
          break;
        case 'Quarterly':
          n = 4;
          break;
        case 'Half-Yearly':
          n = 2;
          break;
        case 'Yearly':
        default:
          n = 1;
          break;
      }
      final double r = rate / 100;
      final double maturity = principal * pow(1 + (r / n), n * years);
      final double interest = maturity - principal;
      return {
        'interest': interest,
        'maturity': maturity,
        'principal': principal,
      };
    }
  }

  static Map<String, double> calculateTax({
    required double amount,
    required double rate,
    required bool isInclusive,
  }) {
    if (amount <= 0 || rate < 0) {
      return {'tax': 0, 'base': 0, 'total': 0};
    }

    if (isInclusive) {
      final double total = amount;
      final double base = double.parse((amount / (1 + (rate / 100))).toStringAsFixed(2));
      final double tax = double.parse((amount - base).toStringAsFixed(2));
      return {
        'tax': tax,
        'base': base,
        'total': total,
      };
    } else {
      final double base = amount;
      final double tax = double.parse((amount * (rate / 100)).toStringAsFixed(2));
      final double total = double.parse((amount + tax).toStringAsFixed(2));
      return {
        'tax': tax,
        'base': base,
        'total': total,
      };
    }
  }
}
