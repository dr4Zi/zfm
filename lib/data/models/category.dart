import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String group; // needs, wants, savings
  @HiveField(3)
  final bool isFixed;
  @HiveField(4)
  final double? plannedPercent;

  const Category({
    required this.id,
    required this.name,
    required this.group,
    required this.isFixed,
    this.plannedPercent,
  });

  Category copyWith({
    String? id,
    String? name,
    String? group,
    bool? isFixed,
    double? plannedPercent,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      isFixed: isFixed ?? this.isFixed,
      plannedPercent: plannedPercent ?? this.plannedPercent,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        group: json['group'] as String,
        isFixed: json['isFixed'] as bool? ?? false,
        plannedPercent: (json['plannedPercent'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'isFixed': isFixed,
        'plannedPercent': plannedPercent,
      };
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Category(
      id: fields[0] as String,
      name: fields[1] as String,
      group: fields[2] as String,
      isFixed: fields[3] as bool,
      plannedPercent: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.group)
      ..writeByte(3)
      ..write(obj.isFixed)
      ..writeByte(4)
      ..write(obj.plannedPercent);
  }
}
