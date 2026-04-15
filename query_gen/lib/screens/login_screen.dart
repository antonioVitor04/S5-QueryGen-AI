import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin        = true;
  bool _loading        = false;
  bool _keepConnected  = false;
  bool _obscure        = true;

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController  = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailController.clear();
    _senhaController.clear();
    _nomeController.clear();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    if (email.isEmpty || senha.isEmpty) {
      _showSnack('Preencha todos os campos', AppColors.red);
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ApiService();
      if (_isLogin) {
        final data = await api.login(email, senha);
        await AuthService().saveToken(data['token'], data['email']);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        await api.register(email, senha);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            // Mesmo layout em web e mobile — só muda a largura máxima
            constraints: const BoxConstraints(maxWidth: 420),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text('Q',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: 'Query',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            TextSpan(
                text: 'Gen',
                style: TextStyle(
                    color: AppColors.accent2,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            TextSpan(
                text: ' AI',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 36),

        // Título
        const Text(
          'Bem vindo de volta!',
          style: TextStyle(
              color: AppColors.text,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'Insira seu e-mail e sua senha para continuar',
          style: TextStyle(color: AppColors.text2, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(children: [
            _buildTab('Entrar', true),
            _buildTab('Cadastrar', false),
          ]),
        ),
        const SizedBox(height: 28),

        // Nome — só no cadastro
        if (!_isLogin) ...[
          _buildField('Nome', 'Insira seu nome', _nomeController),
          const SizedBox(height: 18),
        ],

        // E-mail
        _buildField('E-mail', 'Insira seu e-mail', _emailController,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 18),

        // Senha
        _buildPasswordField(),
        const SizedBox(height: 16),

        // Checkbox + esqueci
        if (_isLogin) _buildBottomRow(),
        const SizedBox(height: 28),

        // Botão principal
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(_isLogin ? 'Entrar' : 'Cadastrar'),
          ),
        ),
        const SizedBox(height: 20),

        // Link alternativo
        GestureDetector(
          onTap: () => setState(() { _isLogin = !_isLogin; _clearFields(); }),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: _isLogin
                      ? 'Não possui uma conta? '
                      : 'Já tem uma conta? ',
                  style: const TextStyle(
                      color: AppColors.text2, fontSize: 14)),
              TextSpan(
                  text: _isLogin ? 'Cadastre-se' : 'Entrar',
                  style: const TextStyle(
                      color: AppColors.accent2,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isLoginTab) {
    final active = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _isLogin = isLoginTab; _clearFields(); }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 12)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : AppColors.text2,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          SizedBox(
            width: 20, height: 20,
            child: Checkbox(
              value: _keepConnected,
              onChanged: (v) => setState(() => _keepConnected = v ?? false),
              activeColor: AppColors.accent,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Continuar conectado',
              style: TextStyle(color: AppColors.text2, fontSize: 13)),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen()),
          ),
          child: const Text('Esqueci minha senha',
              style: TextStyle(
                  color: AppColors.accent2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.text2,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Senha',
            style: TextStyle(
                color: AppColors.text2,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _senhaController,
          obscureText: _obscure,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Insira sua senha',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.text3,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}