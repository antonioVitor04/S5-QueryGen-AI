import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _sql;
  String? _descricao;
  List<String> _tabelas = [];

  static const _sugestoes = [
    'Volume de produção — 3 meses',
    'Faturamento do último mês',
    'Movimentações de estoque',
    'Pedidos de compra abertos',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _gerar() async {
    final pergunta = _controller.text.trim();
    if (pergunta.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _sql = null; });
    try {
      final data = await ApiService().gerarScript(pergunta);
      setState(() {
        _sql       = data['sql'];
        _descricao = data['descricao'];
        _tabelas   = List<String>.from(data['tabelas'] ?? []);
      });
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), AppColors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _copiarSQL() {
    if (_sql == null) return;
    Clipboard.setData(ClipboardData(text: _sql!));
    _showSnack('SQL copiado!', AppColors.green);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: isWide ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: RichText(
        text: const TextSpan(
          children: [
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
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Histórico',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: _logout,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── WEB: input à esquerda, resultado à direita ──
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Painel esquerdo — input
        Container(
          width: 420,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.panel,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputSection(),
              ],
            ),
          ),
        ),
        // Painel direito — resultado
        Expanded(
          child: _sql == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _buildResultCard(),
                ),
        ),
      ],
    );
  }

  // ── MOBILE: tudo em scroll vertical ──
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputSection(),
          if (_sql != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'O que você quer consultar?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Descreva em português o que precisa extrair do SAP',
          style: TextStyle(color: AppColors.text2, fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Campo de texto
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _controller,
            maxLines: 5,
            style: const TextStyle(
                color: AppColors.text, fontSize: 15, height: 1.5),
            decoration: const InputDecoration(
              hintText:
                  'Ex: Quero ver o volume de produção dos últimos 3 meses',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Botão gerar
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _gerar,
            icon: _loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_loading ? 'Gerando...' : 'Gerar Script SQL'),
          ),
        ),
        const SizedBox(height: 24),

        // Sugestões
        const Text('Sugestões',
            style: TextStyle(
                color: AppColors.text2,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sugestoes
              .map((s) => GestureDetector(
                    onTap: () => setState(() => _controller.text = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(s,
                          style: const TextStyle(
                              color: AppColors.text2, fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.code,
                color: AppColors.text3, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Nenhum script gerado ainda',
              style: TextStyle(
                  color: AppColors.text2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Faça uma pergunta no painel ao lado',
              style: TextStyle(color: AppColors.text3, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _descricao ?? 'Script gerado',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text('Sucesso',
                      style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Tags de tabelas
          if (_tabelas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Wrap(
                spacing: 6,
                children: _tabelas
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                  color: AppColors.accent2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // SQL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SelectableText(
              _sql!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppColors.text2,
                height: 1.7,
              ),
            ),
          ),

          // Botão copiar
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _copiarSQL,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar SQL'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}