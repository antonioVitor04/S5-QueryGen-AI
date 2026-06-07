import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';
import '../widgets/app_header.dart';
import '../widgets/chart_widget.dart';
import '../widgets/data_table_widget.dart';
import '../widgets/navbar/navbar.dart';

// Sentinel para o separador não-selecionável no dropdown B
const _kDivider = '__divider__';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  List<dynamic> _history = [];
  bool _loadingHistory = true;
  bool _comparing = false;

  dynamic _selectedA;
  dynamic _selectedB;
  List<dynamic> _similarHistory = [];

  Map<String, dynamic>? _dataA;
  Map<String, dynamic>? _dataB;

  // ── Similaridade ──────────────────────────────────────────────

  static const _stopWords = {
    'a', 'ao', 'aos', 'as', 'até', 'com', 'como', 'da', 'das', 'de',
    'dela', 'delas', 'dele', 'deles', 'do', 'dos', 'e', 'ela', 'elas',
    'ele', 'eles', 'em', 'entre', 'essa', 'essas', 'esse', 'esses',
    'esta', 'estas', 'este', 'estes', 'eu', 'foi', 'há', 'isso', 'isto',
    'já', 'mais', 'mas', 'me', 'muito', 'na', 'nas', 'nem', 'no', 'nos',
    'num', 'numa', 'o', 'os', 'ou', 'para', 'pela', 'pelas', 'pelo',
    'pelos', 'por', 'que', 'se', 'sem', 'seu', 'seus', 'sua', 'suas',
    'também', 'te', 'tem', 'tenho', 'ter', 'teu', 'teus', 'tu', 'tua',
    'tuas', 'um', 'uma', 'umas', 'uns', 'você', 'vocês', 'são', 'estar',
    'ser', 'sendo', 'sido', 'quais', 'qual', 'onde', 'quando', 'todos',
    'todas', 'cada', 'lista', 'mostrar', 'exibir', 'ver', 'quantos',
    'quantas', 'quanto', 'quanta', 'geral', 'total', 'atual',
  };

  Set<String> _extractKeywords(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2 && !_stopWords.contains(w))
      .toSet();

  int _score(dynamic item, Set<String> keywords) {
    final words = _extractKeywords((item['pergunta'] ?? '') as String);
    return words.intersection(keywords).length;
  }

  List<dynamic> _computeSimilar(dynamic pivot) {
    final keywords = _extractKeywords((pivot['pergunta'] ?? '') as String);
    return _history
        .where((item) => item['id'] != pivot['id'])
        .where((item) => _score(item, keywords) > 0)
        .toList()
      ..sort((a, b) => _score(b, keywords).compareTo(_score(a, keywords)));
  }

  // ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await ApiService().getHistorico();
      if (!mounted) return;
      setState(() { _history = data; _loadingHistory = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  void _onSelectA(dynamic v) {
    setState(() {
      _selectedA = v;
      _selectedB = null;
      _similarHistory = _computeSimilar(v);
      _dataA = null;
      _dataB = null;
    });
  }

  Future<void> _compare() async {
    if (_selectedA == null || _selectedB == null) return;
    setState(() { _comparing = true; _dataA = null; _dataB = null; });
    try {
      final results = await Future.wait([
        ApiService().getHistoricoDados(_selectedA['id']),
        ApiService().getHistoricoDados(_selectedB['id']),
      ]);
      if (!mounted) return;
      setState(() {
        _dataA = Map<String, dynamic>.from(results[0]);
        _dataB = Map<String, dynamic>.from(results[1]);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Erro ao carregar dados'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _comparing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    return Scaffold(
      backgroundColor: AppColors.bgOf(context),
      drawer: isWide
          ? null
          : const Drawer(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: NavBar(currentIndex: 2),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide) const NavBar(currentIndex: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeader(title: 'Comparação', showMenuButton: !isWide),
                  Divider(color: AppColors.borderOf(context), height: 1),
                  Expanded(
                    child: SelectionArea(
                      child: _loadingHistory
                          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                          : _history.length < 2
                              ? _buildEmptyState()
                              : _buildContent(isWide),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, color: AppColors.text3Of(context), size: 48),
          const SizedBox(height: 12),
          Text('Scripts insuficientes',
              style: TextStyle(color: AppColors.text2Of(context), fontSize: 15)),
          const SizedBox(height: 6),
          Text('Você precisa de pelo menos 2 scripts gerados para comparar',
              style: TextStyle(color: AppColors.text3Of(context), fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildContent(bool isWide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectorCard(isWide),
          if (_dataA != null && _dataB != null) ...[
            const SizedBox(height: 28),
            _buildComparisonSection(isWide),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectorCard(bool isWide) {
    final canCompare = _selectedA != null &&
        _selectedB != null &&
        _selectedA['id'] != _selectedB['id'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selecione dois scripts para comparar',
              style: TextStyle(
                  color: AppColors.textOf(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Scripts de tema similar aparecem destacados no topo da lista B',
              style: TextStyle(color: AppColors.text3Of(context), fontSize: 12)),
          const SizedBox(height: 16),
          if (isWide)
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: _buildDropdownA()),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(Icons.compare_arrows,
                    color: AppColors.text3Of(context), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdownB()),
            ])
          else
            Column(children: [
              _buildDropdownA(),
              const SizedBox(height: 12),
              _buildDropdownB(),
            ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: (canCompare && !_comparing) ? _compare : null,
              icon: _comparing
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.compare_arrows, size: 18),
              label: Text(_comparing ? 'Carregando...' : 'Comparar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dropdown A — todos os scripts ─────────────────────────────

  Widget _buildDropdownA() {
    final isValueValid = _selectedA != null &&
        _history.any((i) => i['id'] == _selectedA['id']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Script A',
            style: TextStyle(
                color: AppColors.text2Of(context),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _dropdownContainer(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: isValueValid ? _selectedA : null,
              hint: Text('Selecionar script...',
                  style: TextStyle(
                      color: AppColors.text3Of(context), fontSize: 13)),
              isExpanded: true,
              dropdownColor: AppColors.panelOf(context),
              style: TextStyle(color: AppColors.textOf(context), fontSize: 13),
              icon: Icon(Icons.keyboard_arrow_down,
                  color: AppColors.text3Of(context)),
              items: _history.map<DropdownMenuItem<dynamic>>((item) {
                return DropdownMenuItem<dynamic>(
                  value: item,
                  child: Text(item['pergunta'] ?? '',
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                );
              }).toList(),
              onChanged: (v) { if (v != null) _onSelectA(v); },
            ),
          ),
        ),
      ],
    );
  }

  // ── Dropdown B — similares no topo, outros abaixo ─────────────

  Widget _buildDropdownB() {
    final disabled = _selectedA == null;
    final similarIds = _similarHistory.map((i) => i['id']).toSet();
    final others = _history
        .where((i) => i['id'] != _selectedA?['id'] && !similarIds.contains(i['id']))
        .toList();

    final isValueValid = _selectedB != null &&
        _history.any((i) => i['id'] == _selectedB['id']);

    // Monta a lista de itens agrupados
    final List<DropdownMenuItem<dynamic>> menuItems = [];

    if (!disabled) {
      // Similares
      for (final item in _similarHistory) {
        menuItems.add(DropdownMenuItem<dynamic>(
          value: item,
          child: Row(children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item['pergunta'] ?? '',
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ]),
        ));
      }

      // Separador (apenas se houver ambos os grupos)
      if (_similarHistory.isNotEmpty && others.isNotEmpty) {
        menuItems.add(DropdownMenuItem<dynamic>(
          value: _kDivider,
          enabled: false,
          child: Row(children: [
            Expanded(child: Divider(color: AppColors.borderOf(context), height: 1)),
            const SizedBox(width: 8),
            Text('Outros scripts',
                style: TextStyle(
                    color: AppColors.text3Of(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: AppColors.borderOf(context), height: 1)),
          ]),
        ));
      }

      // Demais scripts
      for (final item in others) {
        menuItems.add(DropdownMenuItem<dynamic>(
          value: item,
          child: Text(item['pergunta'] ?? '',
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ));
      }
    }

    final hint = disabled
        ? 'Selecione o Script A primeiro'
        : menuItems.isEmpty
            ? 'Nenhum script disponível'
            : _similarHistory.isNotEmpty
                ? 'Scripts similares no topo...'
                : 'Selecionar script...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Script B',
              style: TextStyle(
                  color: AppColors.text2Of(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          if (!disabled && _similarHistory.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                      color: AppColors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('${_similarHistory.length} similares',
                    style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        _dropdownContainer(
          disabled: disabled,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: isValueValid ? _selectedB : null,
              hint: Text(hint,
                  style: TextStyle(
                      color: AppColors.text3Of(context), fontSize: 13)),
              isExpanded: true,
              dropdownColor: AppColors.panelOf(context),
              style: TextStyle(color: AppColors.textOf(context), fontSize: 13),
              icon: Icon(Icons.keyboard_arrow_down,
                  color: disabled
                      ? AppColors.text3Of(context).withValues(alpha: 0.4)
                      : AppColors.text3Of(context)),
              items: disabled ? null : menuItems,
              onChanged: disabled
                  ? null
                  : (v) {
                      if (v == null || v == _kDivider) return;
                      setState(() {
                        _selectedB = v;
                        _dataA = null;
                        _dataB = null;
                      });
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownContainer({required Widget child, bool disabled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: disabled
            ? AppColors.surfaceOf(context).withValues(alpha: 0.5)
            : AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: child,
    );
  }

  // ── Comparação lado a lado ────────────────────────────────────

  Widget _buildComparisonSection(bool isWide) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSidePanel(_selectedA, _dataA!, 'A')),
          const SizedBox(width: 20),
          Expanded(child: _buildSidePanel(_selectedB, _dataB!, 'B')),
        ],
      );
    }
    return Column(children: [
      _buildSidePanel(_selectedA, _dataA!, 'A'),
      const SizedBox(height: 20),
      _buildSidePanel(_selectedB, _dataB!, 'B'),
    ]);
  }

  Widget _buildSidePanel(
      dynamic item, Map<String, dynamic> data, String side) {
    final dados = List<dynamic>.from(data['dados'] ?? []);
    final tipoGrafico = data['grafico'] ?? 'barra';
    final eixoX = data['eixo_x'] as String?;
    final eixoY = data['eixo_y'] as String?;
    final descricao = (data['descricao'] ?? item['pergunta'] ?? '') as String;
    final borderColor = AppColors.borderOf(context);
    final isA = side == 'A';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: isA ? AppColors.accent : AppColors.accent2,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(side,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(descricao,
                    style: TextStyle(
                        color: AppColors.textOf(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(_iconGrafico(tipoGrafico),
                      color: AppColors.accent2, size: 14),
                  const SizedBox(width: 6),
                  Text(_labelGrafico(tipoGrafico),
                      style: TextStyle(
                          color: AppColors.text2Of(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('${dados.length} registros',
                        style: const TextStyle(
                            color: AppColors.accent2,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 16),
                ChartWidget(
                    dados: dados,
                    tipoGrafico: tipoGrafico,
                    eixoX: eixoX,
                    eixoY: eixoY),
                const SizedBox(height: 20),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 16),
                Row(children: [
                  Icon(Icons.table_chart_outlined,
                      color: AppColors.text2Of(context), size: 14),
                  const SizedBox(width: 6),
                  Text('TABELA DE DADOS',
                      style: TextStyle(
                          color: AppColors.text2Of(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
                  if (dados.length > 100) ...[
                    const Spacer(),
                    Text('100 primeiros',
                        style: TextStyle(
                            color: AppColors.text3Of(context), fontSize: 10)),
                  ],
                ]),
                const SizedBox(height: 12),
                DataTableWidget(dados: dados),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconGrafico(String tipo) {
    switch (tipo) {
      case 'pizza': return Icons.pie_chart_outline;
      case 'linha': return Icons.show_chart;
      default:      return Icons.bar_chart;
    }
  }

  String _labelGrafico(String tipo) {
    switch (tipo) {
      case 'pizza': return 'GRÁFICO DE PIZZA';
      case 'linha': return 'GRÁFICO DE LINHA';
      default:      return 'GRÁFICO DE BARRAS';
    }
  }
}
