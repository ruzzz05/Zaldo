import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/domain/amount_parser.dart';

void main() {
  test('parses comma decimal to cents', () {
    final r = parseAmount('4,50');
    expect(r.cents, 450);
    expect(r.error, isNull);
  });

  test('parses dot decimal to cents', () {
    expect(parseAmount('4.5').cents, 450);
  });

  test('parses integer', () {
    expect(parseAmount('12').cents, 1200);
  });

  test('trims whitespace', () {
    expect(parseAmount('  3,20 ').cents, 320);
  });

  test('empty gives empty error', () {
    expect(parseAmount('   ').error, AmountError.empty);
  });

  test('zero gives notPositive error', () {
    expect(parseAmount('0').error, AmountError.notPositive);
    expect(parseAmount('0,00').error, AmountError.notPositive);
  });

  test('negative gives notPositive error', () {
    expect(parseAmount('-5').error, AmountError.notPositive);
  });

  test('text gives invalid error', () {
    expect(parseAmount('abc').error, AmountError.invalid);
    expect(parseAmount('4,5,0').error, AmountError.invalid);
  });

  test('more than two decimals gives invalid error', () {
    expect(parseAmount('4,505').error, AmountError.invalid);
  });
}
