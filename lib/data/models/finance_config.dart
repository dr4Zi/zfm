import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class FinanceConfig {
  @HiveField(0)
  final double monthlyIncome;
  @HiveField(1)
  final Map<String, double> groupPercent; // e.g., {needs: 0.5, wants: 0.3, savings: 0.2}

  const FinanceConfig({
    required this.monthlyIncome,
    required this.groupPercent,
  });

  FinanceConfig copyWith({double? monthlyIncome, Map<String, double>? groupPercent}) => FinanceConfig(
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        groupPercent: groupPercent ?? this.groupPercent,
      );

  factory FinanceConfig.fromJson(Map<String, dynamic> json) {
    final raw = (json['groupPercent'] as Map).map((key, value) => MapEntry(key.toString(), (value as num).toDouble()));
    return FinanceConfig(
      monthlyIncome: (json['monthlyIncome'] as num? ?? 0).toDouble(),
      groupPercent: raw,
    );
  }

  Map<String, dynamic> toJson() => {
        'monthlyIncome': monthlyIncome,
        'groupPercent': groupPercent,
      };
}

class FinanceConfigAdapter extends TypeAdapter<FinanceConfig> {
  @override
  final int typeId = 3;

  @override
  FinanceConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FinanceConfig(
      monthlyIncome: fields[0] as double,
      groupPercent: (fields[1] as Map).map((key, value) => MapEntry(key as String, (value as num).toDouble())),
    );
  }

  @override
  void write(BinaryWriter writer, FinanceConfig obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.monthlyIncome)
      ..writeByte(1)
      ..write(obj.groupPercent);
  }
}
