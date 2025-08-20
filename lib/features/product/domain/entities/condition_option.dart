import 'package:equatable/equatable.dart';

class ConditionOption extends Equatable {
  final String code;   // never_worn / as_new / good / fair
  final int order;

  const ConditionOption({required this.code, required this.order});

  factory ConditionOption.fromMap(Map<String, dynamic> m) => ConditionOption(
    code: m['code'] as String,
    order: (m['display_order'] as num).toInt(),
  );

  @override
  List<Object?> get props => [code, order];
}
