import 'package:flutter/material.dart';

class AppRtl {
  static TextDirection getTextDirection(BuildContext context) {
    return Directionality.of(context);
  }

  static AlignmentDirectional startAlignment(BuildContext context) {
    return AlignmentDirectional.centerStart;
  }

  static AlignmentDirectional endAlignment(BuildContext context) {
    return AlignmentDirectional.centerEnd;
  }
}
