import 'category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.date,
    this.description = '',
  });

  final String id;
  final int amountCents;
  final Category category;
  final DateTime date;
  final String description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountCents': amountCents,
    'category': category.name,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'] as String,
    amountCents: j['amountCents'] as int,
    category: Category.values.byName(j['category'] as String),
    date: DateTime.parse(j['date'] as String),
    description: (j['description'] as String?) ?? '',
  );
}
