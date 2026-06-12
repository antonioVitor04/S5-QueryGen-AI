import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_notifier.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/routes.dart';
import 'main_shell.dart';
import 'forgot_password_screen.dart';
import 'terms_of_use_screen.dart';
import 'privacy_policy_screen.dart';
import '../widgets/graphics/activity_bars_widget.dart';
import '../widgets/graphics/bar_chart_widget.dart';
import '../widgets/graphics/donut_chart_widget.dart';
import '../widgets/graphics/line_chart_widget.dart';
import '../widgets/graphics/stat_pill_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  final _emailController        = TextEditingController();
  final _senhaController        = TextEditingController();
  final _nomeController         = TextEditingController();
  final _confirmSenhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    _confirmSenhaController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailController.clear();
    _senhaController.clear();
    _nomeController.clear();
    _confirmSenhaController.clear();
    setState(() => _acceptedTerms = false);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  String? _validatePassword(String password) {
    if (password.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'A senha deve conter pelo menos uma letra maiúscula';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'A senha deve conter pelo menos um número';
    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?]').hasMatch(password)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _showSnack('Preencha todos os campos', AppColors.red);
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack('Insira um e-mail válido', AppColors.red);
      return;
    }
    if (!_isLogin) {
      final passwordError = _validatePassword(senha);
      if (passwordError != null) { _showSnack(passwordError, AppColors.red); return; }
      final confirm = _confirmSenhaController.text.trim();
      if (senha != confirm) { _showSnack('As senhas não coincidem', AppColors.red); return; }
      if (!_acceptedTerms) { _showSnack('Aceite os Termos de Uso e a Política de Privacidade', AppColors.red); return; }
    }

    setState(() => _loading = true);
    try {
      final api = ApiService();
      if (_isLogin) {
        final data = await api.login(email, senha);
        await AuthService().saveToken(data['token'], data['email'], nome: data['nome'] as String?);
        if (!mounted) return;
        Navigator.pushReplacement(context, fadeRoute(const MainShell()));
      } else {
        final nome = _nomeController.text.trim();
        await api.register(email, senha, nome);
        if (!mounted) return;
        _showSnack('Conta criada! Faça login.', AppColors.green);
        setState(() { _isLogin = true; _clearFields(); });
      }
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showLegalModal(String title, List<Map<String, String>> sections, String subtitle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.panelOf(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Stack(
            children: [
              // CONTEÚDO DO MODAL
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    // LOGO (Igual à sua definição oficial)
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset('assets/Logo QueryGen (1).png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 16),
                    
                    // TÍTULO
                    Text(
                      title,
                      style: TextStyle(color: AppColors.textOf(context), fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // SUBTÍTULO
                    Text(
                      subtitle,
                      style: TextStyle(color: AppColors.text2Of(context), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // ÁREA DE TEXTO COM SCROLL
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sections.map((sec) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sec['title']!,
                                  style: const TextStyle(color: AppColors.accent2, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  sec['content']!,
                                  style: TextStyle(color: AppColors.textOf(context), fontSize: 14, height: 1.5),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BOTÃO FECHAR (X) - Superior Direito
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: AppColors.text3Of(context), size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showTerms() {
    _showLegalModal(
      'Termos de Uso',
      [
        {'title': '1. Uso da Plataforma', 'content': 'O usuário se compromete a utilizar o sistema de forma responsável, ética e dentro das leis vigentes. O acesso à plataforma é pessoal e intransferível.'},
        {'title': '2. Conta do Usuário', 'content': 'Você é responsável pela segurança da sua conta e das informações fornecidas durante o cadastro. Mantenha sua senha em sigilo e não compartilhe suas credenciais.'},
        {'title': '3. Proibições', 'content': 'É proibido utilizar a plataforma para spam, ataques ou qualquer atividade maliciosa. Tentativas de acesso não autorizado serão reportadas às autoridades competentes.'},
        {'title': '4. Propriedade Intelectual', 'content': 'Todo o conteúdo disponível na plataforma é protegido por direitos autorais. É vedada a reprodução, distribuição ou modificação sem autorização prévia.'},
        {'title': '5. Limitação de Responsabilidade', 'content': 'A plataforma não se responsabiliza por danos indiretos decorrentes do uso ou da incapacidade de uso dos serviços oferecidos.'},
        {'title': '6. Alterações nos Termos', 'content': 'Reservamos o direito de modificar estes termos a qualquer momento. O uso continuado da plataforma após as alterações constitui aceitação dos novos termos.'},
      ],
      'Ao utilizar esta plataforma, você concorda com todos os termos e condições estabelecidos neste documento.',
    );
  }

  void showPrivacy() {
    _showLegalModal(
      'Política de Privacidade',
      [
        {'title': '1. Coleta de Dados', 'content': 'Coletamos apenas informações necessárias para o funcionamento da plataforma, como nome, e-mail e dados de uso. Não coletamos dados sensíveis sem consentimento explícito.'},
        {'title': '2. Compartilhamento', 'content': 'Não compartilhamos seus dados pessoais com terceiros sem autorização, exceto quando exigido por lei ou para prestação dos serviços contratados.'},
        {'title': '3. Segurança', 'content': 'Aplicamos medidas técnicas e organizacionais para proteger suas informações contra acesso não autorizado, perda ou destruição acidental.'},
        {'title': '4. Cookies', 'content': 'Utilizamos cookies para melhorar sua experiência. Você pode desativá-los nas configurações do navegador, mas isso pode afetar algumas funcionalidades.'},
        {'title': '5. Seus Direitos', 'content': 'Você tem direito de acessar, corrigir ou solicitar a exclusão de seus dados pessoais a qualquer momento, conforme previsto pela LGPD.'},
        {'title': '6. Retenção de Dados', 'content': 'Mantemos seus dados pelo tempo necessário para a prestação dos serviços ou conforme exigido por obrigações legais. Após esse período, os dados são excluídos com segurança.'},
      ],
      'Sua privacidade é importante para nós. Todas as informações fornecidas são protegidas e armazenadas com segurança.',
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;

    if (!isDesktop) {
      // No Mobile, renderiza apenas o esquerdo com o scroll interno ativo
      return Scaffold(
        backgroundColor: AppColors.bgOf(context),
        body: Stack(
          children: [
            _buildLeftPanel(disableScroll: false),
            _buildThemeButton(context),
          ],
        ),
      );
    }

    // No Desktop, limpamos os scrolls internos e usamos apenas o Global
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildLeftPanel(disableScroll: true),
                      ),
                      Expanded(
                        flex: 6,
                        child: _buildRightPanel(disableScroll: true),
                      ),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
          _buildThemeButton(context),
        ],
      ),
    );
  }

  Widget _buildThemeButton(BuildContext context) {
    final notifier = MyApp.of(context);
    final isDark = notifier.isDark;
    return Positioned(
      top: 16,
      right: 16,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: IconButton(
          key: ValueKey(isDark),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: AppColors.text2Of(context),
            size: 22,
          ),
          tooltip: isDark ? 'Modo claro' : 'Modo escuro',
          onPressed: notifier.toggle,
        ),
      ),
    );
  }

 Widget _buildFooter() {
    final headerStyle = TextStyle(
      color: AppColors.textOf(context),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    final infoStyle = TextStyle(
      color: AppColors.text2Of(context),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    final hPad = (MediaQuery.of(context).size.width * 0.06).clamp(24.0, 80.0);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 60),
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        border: Border(
          top: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  'assets/Logo QueryGen (1).png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Navegação', style: headerStyle),
                const SizedBox(height: 24),
                Text('Home page', style: infoStyle),
                const SizedBox(height: 16),
                Text('Geração de scripts', style: infoStyle),
                const SizedBox(height: 16),
                Text('Histórico', style: infoStyle),
                const SizedBox(height: 16),
                Text('Perfil', style: infoStyle),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Serviços', style: headerStyle),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: showTerms,
                  child: Text('Termos e condições', style: infoStyle),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: showPrivacy,
                  child: Text('Política de privacidade', style: infoStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel({bool disableScroll = false}) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: _buildForm(),
      ),
    );

    if (disableScroll) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: content,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: content,
    );
  }

  Widget _buildRightPanel({bool disableScroll = false}) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StatPillsRow(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  flex: 5,
                  child: SizedBox(height: 280, child: LineChartWidget()),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: SizedBox(height: 280, child: DonutChartWidget()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  flex: 4,
                  child: SizedBox(height: 280, child: BarChartWidget()),
                ),
                SizedBox(width: 24),
                Expanded(
                  flex: 5,
                  child: SizedBox(height: 280, child: ActivityBarsWidget()),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgOf(context),
        border: Border(
          left: BorderSide(color: AppColors.borderOf(context), width: 1),
        ),
      ),
      child: disableScroll
          ? Padding(padding: const EdgeInsets.all(48), child: content)
          : SingleChildScrollView(padding: const EdgeInsets.all(48), child: content),
    );
  }
  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90, height: 90,
          child: Image.asset('assets/Logo QueryGen (1).png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Query',
                style: TextStyle(color: AppColors.textOf(context), fontSize: 18, fontWeight: FontWeight.w700)),
            const TextSpan(text: 'Gen',
                style: TextStyle(color: AppColors.accent2, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 36),

        Text(
          _isLogin ? 'Bem vindo de volta!' : 'Crie sua conta',
          style: TextStyle(color: AppColors.textOf(context), fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin ? 'Insira seu e-mail e sua senha para continuar' : 'Preencha os dados abaixo para se cadastrar',
          style: TextStyle(color: AppColors.text2Of(context), fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // TAB SELECTOR
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                  ),
                ),
              ),
              Row(children: [_buildTab('Entrar', true), _buildTab('Cadastrar', false)]),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (!_isLogin) ...[
          _buildField(context, 'Nome', 'Seu nome completo', _nomeController),
          const SizedBox(height: 16),
        ],
        _buildField(context, 'E-mail', 'exemplo@email.com', _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 18),

        _buildPasswordField(context,
          label: 'Senha',
          hint: _isLogin ? 'Insira sua senha' : 'Mínimo 8 caracteres',
          controller: _senhaController,
          obscure: _obscure,
          onToggle: () => setState(() => _obscure = !_obscure),
        ),

        if (!_isLogin) ...[
          const SizedBox(height: 6),
          Text('Use 8+ caracteres com maiúscula, número e caractere especial.',
              style: TextStyle(color: AppColors.text3Of(context), fontSize: 11, height: 1.4)),
          const SizedBox(height: 18),
          _buildPasswordField(context,
            label: 'Confirmar senha',
            hint: 'Repita sua senha',
            controller: _confirmSenhaController,
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 20),

          // CHECKBOX DE ACEITE
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20, width: 20,
                child: Checkbox(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  activeColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: AppColors.borderOf(context), width: 1.5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  children: [
                    Text('Li e aceito os ', style: TextStyle(color: AppColors.text2Of(context), fontSize: 12)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, fadeRoute(const TermsOfUseScreen())),
                      child: const Text('Termos de Uso',
                          style: TextStyle(color: AppColors.accent2, fontSize: 12, fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline, decorationColor: AppColors.accent2)),
                    ),
                    Text(' e a ', style: TextStyle(color: AppColors.text2Of(context), fontSize: 12)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, fadeRoute(const PrivacyPolicyScreen())),
                      child: const Text('Política de Privacidade',
                          style: TextStyle(color: AppColors.accent2, fontSize: 12, fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline, decorationColor: AppColors.accent2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),
        if (_isLogin) _buildBottomRow(context),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity, height: 45,
          child: ElevatedButton(
            onPressed: (_loading || (!_isLogin && !_acceptedTerms)) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isLogin ? 'Entrar' : 'Cadastrar'),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isLoginTab) {
    final active = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() { _isLogin = isLoginTab; _clearFields(); });
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: active ? Colors.white : AppColors.text2Of(context),
              fontSize: 13, fontWeight: FontWeight.w600,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, fadeRoute(const ForgotPasswordScreen())),
          child: const Text('Esqueci a senha',
              style: TextStyle(color: AppColors.accent2, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildField(BuildContext context, String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.text2Of(context), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.textOf(context), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.text3Of(context), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.borderOf(context))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.borderOf(context))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            filled: true,
            fillColor: AppColors.surfaceOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, {
    required String label, required String hint,
    required TextEditingController controller,
    required bool obscure, required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.text2Of(context), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: AppColors.textOf(context), fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.text3Of(context), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.borderOf(context))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.borderOf(context))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            filled: true,
            fillColor: AppColors.surfaceOf(context),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.text3Of(context), size: 20),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}