import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/domain/format.dart';

void main() {
  test('formats cents as euros with comma', () {
    expect(formatEuros(450), '4,50 €');
    expect(formatEuros(5), '0,05 €');
    expect(formatEuros(123456), '1234,56 €');
  });
  test('spoken euros for screen readers', () {
    expect(spokenEuros(450), '4 euros con 50 céntimos');
    expect(spokenEuros(500), '5 euros');
    expect(spokenEuros(100), '1 euro');
    expect(spokenEuros(5), '5 céntimos');
    expect(spokenEuros(101), '1 euro con 1 céntimo');
  });
  test('formats date as day month year in Spanish', () {
    expect(formatDate(DateTime(2026, 11, 3)), '3 de noviembre de 2026');
  });
  test('formats month', () {
    expect(formatMonth(DateTime(2026, 3, 9)), 'Marzo de 2026');
  });
  test('decimal input for editing', () {
    expect(centsToInput(450), '4,50');
  });
}
