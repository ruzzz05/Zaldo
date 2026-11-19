enum AmountError { empty, invalid, notPositive }

class AmountResult {
  const AmountResult.ok(int this.cents) : error = null;
  const AmountResult.fail(AmountError this.error) : cents = null;
  final int? cents;
  final AmountError? error;
}

final _amountPattern = RegExp(r'^-?\d+([.,]\d{1,2})?$');

/// Parses a user-typed euro amount ("4,50", "4.5", "12") into cents.
AmountResult parseAmount(String input) {
  final text = input.trim();
  if (text.isEmpty) return const AmountResult.fail(AmountError.empty);
  if (!_amountPattern.hasMatch(text)) {
    return const AmountResult.fail(AmountError.invalid);
  }
  final negative = text.startsWith('-');
  final parts = text.replaceFirst('-', '').split(RegExp(r'[.,]'));
  final euros = int.parse(parts[0]);
  final decimals = parts.length > 1 ? int.parse(parts[1].padRight(2, '0')) : 0;
  final cents = euros * 100 + decimals;
  if (negative || cents <= 0) {
    return const AmountResult.fail(AmountError.notPositive);
  }
  return AmountResult.ok(cents);
}
