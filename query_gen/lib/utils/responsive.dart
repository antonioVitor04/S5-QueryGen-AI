import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Responsive {
  static bool get isWeb => kIsWeb;

  // Largura de corte: acima disso usa layout web
  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  // Helper para escolher valor baseado na plataforma
  static T choose<T>(BuildContext context, {required T mobile, required T web}) =>
      isWide(context) ? web : mobile;
}