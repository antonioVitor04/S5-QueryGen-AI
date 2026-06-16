import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_notifier.dart';
import '../main.dart';
import '../widgets/graphics/activity_bars_widget.dart';
import '../widgets/graphics/bar_chart_widget.dart';
import '../widgets/graphics/donut_chart_widget.dart';
import '../widgets/graphics/line_chart_widget.dart';
import '../widgets/graphics/stat_pill_widget.dart';
import '../utils/legal_texts.dart';
import '../utils/responsive.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final ThemeNotifier notifier = MyApp.of(context);
    final bool isDark = notifier.isDark;

    final themeButton = Positioned(
      top: 16, right: 16,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: IconButton(
          key: ValueKey(isDark),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: AppColors.text2Of(context), size: 22,
          ),
          tooltip: isDark ? 'Modo claro' : 'Modo escuro',
          onPressed: notifier.toggle,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: Stack(
        children: [
          isDesktop
              ? Row(children: [
                  Expanded(flex: 4, child: _buildContent(context)),
                  Expanded(flex: 6, child: _buildRightPanel(context)),
                ])
              : _buildContent(context),
          themeButton,
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 70, height: 70,
                      child: Image.asset('assets/Logo QueryGen.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'Query',
                            style: TextStyle(color: AppColors.textOf(context), fontSize: 16, fontWeight: FontWeight.w700)),
                        const TextSpan(text: 'Gen',
                            style: TextStyle(color: AppColors.accent2, fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Text('Política de Privacidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textOf(context), fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(height: 16),

              Text(LegalTexts.privacySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.text2Of(context), fontSize: 13, height: 1.6)),
              const SizedBox(height: 24),

              ...LegalTexts.privacySections.map((sec) => _buildSection(context, sec.title, sec.content)),

              const SizedBox(height: 32),

              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.text3Of(context), size: 14),
                      const SizedBox(width: 6),
                      Text('Voltar para cadastro', style: TextStyle(color: AppColors.text3Of(context), fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.accent2, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)),
          const SizedBox(height: 6),
          Text(content, style: TextStyle(color: AppColors.text2Of(context), fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }

Widget _buildRightPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgOf(context),
        border: Border(
          left: BorderSide(color: AppColors.borderOf(context), width: 1),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatPillsRow(),
                SizedBox(height: 24),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 5, child: SizedBox(height: 280, child: LineChartWidget())),
                  SizedBox(width: 24),
                  Expanded(flex: 4, child: SizedBox(height: 280, child: DonutChartWidget())),
                ]),
                SizedBox(height: 24),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 4, child: SizedBox(height: 280, child: BarChartWidget())),
                  SizedBox(width: 24),
                  Expanded(flex: 5, child: SizedBox(height: 280, child: ActivityBarsWidget())),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}