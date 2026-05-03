class Expense {
  final String id;
  final double amount;
  final String categoryId;
  final String date;
  final String note;
  final String createdAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
    this.createdAt = '',
  });

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id:         j['id'] as String,
        amount:     (j['amount'] as num).toDouble(),
        categoryId: j['categoryId'] as String,
        date:       j['date'] as String,
        note:       j['note'] as String? ?? '',
        createdAt:  j['createdAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'amount':     amount,
        'categoryId': categoryId,
        'date':       date,
        'note':       note,
      };

  Expense copyWith({double? amount, String? categoryId, String? date, String? note}) =>
      Expense(
        id:         id,
        amount:     amount     ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        date:       date       ?? this.date,
        note:       note       ?? this.note,
        createdAt:  createdAt,
      );
}
