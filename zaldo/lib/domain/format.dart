const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String centsToInput(int cents) =>
    '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';

String formatEuros(int cents) => '${centsToInput(cents)} €';

String spokenEuros(int cents) {
  final e = cents ~/ 100;
  final c = cents % 100;
  final euros = e == 1 ? '1 euro' : '$e euros';
  final cents_ = c == 1 ? '1 céntimo' : '$c céntimos';
  if (e == 0) return cents_;
  return c == 0 ? euros : '$euros con $c ${c == 1 ? 'céntimo' : 'céntimos'}';
}

String formatDate(DateTime d) =>
    '${d.day} de ${_months[d.month - 1]} de ${d.year}';

String formatShortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String formatMonth(DateTime d) {
  final m = _months[d.month - 1];
  return '${m[0].toUpperCase()}${m.substring(1)} de ${d.year}';
}

const _weekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

String weekdayName(DateTime d) => _weekdays[d.weekday - 1];

/// One letter, for narrow chart axes ("L", "M", "X"...).
String weekdayInitial(DateTime d) => 'LMXJVSD'[d.weekday - 1];

/// "martes 17 de noviembre", for screen readers.
String spokenDay(DateTime d) =>
    '${weekdayName(d)} ${d.day} de ${_months[d.month - 1]}';
