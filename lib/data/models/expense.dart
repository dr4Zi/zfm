import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class Expense {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String categoryId;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String? note;

  const Expense({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note,
  });

  Expense copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) => Expense(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note,
      );

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Expense(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note);
  }
}
