import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoRouterRefreshStreamFromRiverpod extends ChangeNotifier {
  GoRouterRefreshStreamFromRiverpod(WidgetRef ref, ProviderListenable provider) {
   ref.listen(provider, (previous, next) => notifyListeners());

  }
}
