import 'package:flutter/widgets.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import '../entities/item_condition.dart';

String itemConditionLabel(BuildContext context, String code) {
  final l = AppLocalizations.of(context)!;
  switch (code) {
    case ItemCondition.neverWorn: return l.conditionNeverWorn;
    case ItemCondition.asNew:     return l.conditionAsNew;
    case ItemCondition.good:      return l.conditionGood;
    case ItemCondition.fair:      return l.conditionFair;
    default:                      return code; // fallback
  }
}
