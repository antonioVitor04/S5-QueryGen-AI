import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Responsive {
  static bool get isWeb => kIsWeb;

  // Largura de corte: acima disso usa layout web (navbar lateral)
  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  // Largura de corte das telas de autenticação/legal: acima disso usa
  // layout de duas colunas (formulário + painel gráfico)
  static const desktopBreakpoint = 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > desktopBreakpoint;

  // Helper para escolher valor baseado na plataforma
  static T choose<T>(BuildContext context, {required T mobile, required T web}) =>
      isWide(context) ? web : mobile;
}