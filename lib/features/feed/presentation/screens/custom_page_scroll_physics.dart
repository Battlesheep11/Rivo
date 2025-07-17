import 'package:flutter/widgets.dart';

/// Custom physics to make it easier to change pages in PageView (less scroll required in both directions).
class CustomPageScrollPhysics extends PageScrollPhysics {
  const CustomPageScrollPhysics({super.parent});

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageScrollPhysics(parent: buildParent(ancestor));
  }

  // Lower this value to make it easier to trigger a page change
  @override
  double get dragStartDistanceMotionThreshold => 8.0; // default is 16.0

  // Make both up and down scrolls equally sensitive by lowering the velocity threshold
  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // If user is out of range, defer to parent
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    // Lower the velocity threshold for page changes (default is 1.0)
    const double minFlingVelocity = 0.2;
    if (velocity.abs() < minFlingVelocity) {
      return null;
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

