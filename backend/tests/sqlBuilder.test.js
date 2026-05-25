const { buildSQL } = require('../src/sap/sqlBuilder');

// ── Utilitário ────────────────────────────────────────────────────────────────
function testar(nome, fn) {
  try {
    fn();
    console.log(`  ✔ ${nome}`);
  } catch (err) {
    console.error(`  ✘ ${nome}`);
    console.error(`    ${err.message}`);
  }
}

function esperar(valor, esperado, mensagem) {
  if (!valor.includes(esperado)) {
    throw new Error(`${mensagem}\n    Esperado: "${esperado}"\n    Recebido: "${valor}"`);
  }
}

function esperarErro(fn, msgEsperada) {
  try {
    fn();
    throw new Error(`Deveria ter lançado erro com: "${msgEsperada}"`);
  } catch (err) {
    if (!err.message.includes(msgEsperada)) {
      throw new Error(`Erro errado. Esperado: "${msgEsperada}", Recebido: "${err.message}"`);
    }
  }
}

// ── Testes ────────────────────────────────────────────────────────────────────
console.log('\n=== SQLBUILDER TESTS ===\n');

console.log('[ 1 ] Consultas simples (sem JOIN):');

testar('Tabela única com campos corretos', () => {
  const sql = buildSQL({
    tabelas: ['AFKO'],
    campos:  ['AFKO.AUFNR', 'AFKO.GAMNG', 'AFKO.GSTRI'],
    joins:   [],
    filtros: {},
  });
  esperar(sql, 'SELECT sap_afko.AUFNR, sap_afko.GAMNG, sap_afko.GSTRI', 'SELECT incorreto');
  esperar(sql, 'FROM sap_afko', 'FROM incorreto');
  esperar(sql, 'LIMIT 1000', 'LIMIT ausente');
});

testar('Tabela de faturamento sem filtros', () => {
  const sql = buildSQL({
    tabelas: ['VBRK'],
    campos:  ['VBRK.VBELN', 'VBRK.FKDAT', 'VBRK.NETWR'],
    joins:   [],
    filtros: {},
  });
  esperar(sql, 'FROM sap_vbrk', 'Tabela incorreta');
  esperar(sql, 'sap_vbrk.NETWR', 'Campo NETWR incorreto');
});

testar('Estoque por material', () => {
  const sql = buildSQL({
    tabelas: ['MARD'],
    campos:  ['MARD.MATNR', 'MARD.LABST'],
    joins:   [],
    filtros: {},
  });
  esperar(sql, 'FROM sap_mard', 'Tabela incorreta');
  esperar(sql, 'sap_mard.LABST', 'Campo LABST incorreto');
});

console.log('\n[ 2 ] Filtros de período:');

testar('Filtro periodo_dias correto', () => {
  const sql = buildSQL({
    tabelas: ['AFKO'],
    campos:  ['AFKO.AUFNR', 'AFKO.GAMNG'],
    joins:   [],
    filtros: { periodo_dias: 90, campo_data: 'AFKO.GSTRI' },
  });
  esperar(sql, 'WHERE sap_afko.GSTRI >= DATE_SUB(NOW(), INTERVAL 90 DAY)', 'Filtro incorreto');
});

testar('Filtro de 30 dias em movimentações', () => {
  const sql = buildSQL({
    tabelas: ['MSEG'],
    campos:  ['MSEG.MATNR', 'MSEG.MENGE', 'MSEG.BUDAT'],
    joins:   [],
    filtros: { periodo_dias: 30, campo_data: 'MSEG.BUDAT' },
  });
  esperar(sql, 'INTERVAL 30 DAY', 'Intervalo incorreto');
  esperar(sql, 'sap_mseg.BUDAT', 'Campo data incorreto');
});

testar('Filtro data_inicio e data_fim', () => {
  const sql = buildSQL({
    tabelas: ['VBRK'],
    campos:  ['VBRK.VBELN', 'VBRK.NETWR'],
    joins:   [],
    filtros: {
      campo_data:  'VBRK.FKDAT',
      data_inicio: '2024-01-01',
      data_fim:    '2024-12-31',
    },
  });
  esperar(sql, "BETWEEN '2024-01-01' AND '2024-12-31'", 'BETWEEN incorreto');
});

testar('Sanitização de datas (remove caracteres especiais)', () => {
  const sql = buildSQL({
    tabelas: ['VBRK'],
    campos:  ['VBRK.VBELN'],
    joins:   [],
    filtros: {
      campo_data:  'VBRK.FKDAT',
      data_inicio: "2024-01-01'; DROP TABLE--",
      data_fim:    '2024-12-31',
    },
  });
  if (sql.includes('DROP')) throw new Error('SQL injection não foi sanitizado');
});

console.log('\n[ 3 ] JOINs:');

testar('JOIN simples EKKO → EKPO', () => {
  const sql = buildSQL({
    tabelas: ['EKKO', 'EKPO'],
    campos:  ['EKKO.EBELN', 'EKPO.MENGE', 'EKPO.NETPR'],
    joins:   [{ tabela: 'EKPO', on: 'EKKO.EBELN = EKPO.EBELN' }],
    filtros: {},
  });
  esperar(sql, 'JOIN sap_ekpo ON sap_ekko.EBELN = sap_ekpo.EBELN', 'JOIN incorreto');
});

testar('JOIN duplo EKKO → EKPO → LFA1', () => {
  const sql = buildSQL({
    tabelas: ['EKKO', 'EKPO', 'LFA1'],
    campos:  ['EKKO.EBELN', 'LFA1.NAME1', 'EKPO.MENGE'],
    joins:   [
      { tabela: 'EKPO', on: 'EKKO.EBELN = EKPO.EBELN' },
      { tabela: 'LFA1', on: 'EKKO.LIFNR = LFA1.LIFNR' },
    ],
    filtros: {},
  });
  esperar(sql, 'JOIN sap_ekpo ON sap_ekko.EBELN = sap_ekpo.EBELN', 'Primeiro JOIN incorreto');
  esperar(sql, 'JOIN sap_lfa1 ON sap_ekko.LIFNR = sap_lfa1.LIFNR', 'Segundo JOIN incorreto');
  esperar(sql, 'sap_lfa1.NAME1', 'Campo NAME1 incorreto');
});

testar('JOIN faturamento com cliente VBRK → KNA1', () => {
  const sql = buildSQL({
    tabelas: ['VBRK', 'KNA1'],
    campos:  ['VBRK.VBELN', 'VBRK.NETWR', 'KNA1.NAME1'],
    joins:   [{ tabela: 'KNA1', on: 'VBRK.KUNAG = KNA1.KUNNR' }],
    filtros: { periodo_dias: 30, campo_data: 'VBRK.FKDAT' },
  });
  esperar(sql, 'JOIN sap_kna1 ON sap_vbrk.KUNAG = sap_kna1.KUNNR', 'JOIN KNA1 incorreto');
  esperar(sql, 'sap_kna1.NAME1', 'Campo NAME1 incorreto');
});

testar('JOIN com filtro de período', () => {
  const sql = buildSQL({
    tabelas: ['EKKO', 'EKPO', 'LFA1'],
    campos:  ['EKKO.EBELN', 'LFA1.NAME1', 'EKPO.MENGE'],
    joins:   [
      { tabela: 'EKPO', on: 'EKKO.EBELN = EKPO.EBELN' },
      { tabela: 'LFA1', on: 'EKKO.LIFNR = LFA1.LIFNR' },
    ],
    filtros: { periodo_dias: 90, campo_data: 'EKKO.BEDAT' },
  });
  esperar(sql, 'WHERE sap_ekko.BEDAT >= DATE_SUB(NOW(), INTERVAL 90 DAY)', 'WHERE com JOIN incorreto');
});

console.log('\n[ 4 ] Erros esperados:');

testar('Erro: tabelas vazio', () => {
  esperarErro(
    () => buildSQL({ tabelas: [], campos: ['AFKO.AUFNR'], joins: [], filtros: {} }),
    'Nenhuma tabela'
  );
});

testar('Erro: campos vazio', () => {
  esperarErro(
    () => buildSQL({ tabelas: ['AFKO'], campos: [], joins: [], filtros: {} }),
    'Nenhum campo'
  );
});

testar('Erro: tabela inexistente no banco', () => {
  esperarErro(
    () => buildSQL({ tabelas: ['ZTABELA_FAKE'], campos: ['ZTABELA_FAKE.CAMPO'], joins: [], filtros: {} }),
    'não existe no banco'
  );
});

testar('Erro: input nulo', () => {
  esperarErro(
    () => buildSQL(null),
    'inválida'
  );
});

console.log('\n[ 5 ] Cenários reais (perguntas do sistema):');

testar('Volume de produção dos últimos 3 meses', () => {
  const sql = buildSQL({
    tabelas: ['AFKO'],
    campos:  ['AFKO.AUFNR', 'AFKO.MATNR', 'AFKO.GAMNG', 'AFKO.GSTRI'],
    joins:   [],
    filtros: { periodo_dias: 90, campo_data: 'AFKO.GSTRI' },
    grafico: 'linha',
    eixo_x:  'GSTRI',
    eixo_y:  'GAMNG',
  });
  esperar(sql, 'FROM sap_afko', 'Tabela errada');
  esperar(sql, 'INTERVAL 90 DAY', 'Período errado');
});

testar('Faturamento por cliente último mês', () => {
  const sql = buildSQL({
    tabelas: ['VBRK', 'KNA1'],
    campos:  ['KNA1.NAME1', 'VBRK.NETWR', 'VBRK.FKDAT'],
    joins:   [{ tabela: 'KNA1', on: 'VBRK.KUNAG = KNA1.KUNNR' }],
    filtros: { periodo_dias: 30, campo_data: 'VBRK.FKDAT' },
    grafico: 'barra',
    eixo_x:  'NAME1',
    eixo_y:  'NETWR',
  });
  esperar(sql, 'sap_kna1.NAME1', 'Campo cliente errado');
  esperar(sql, 'sap_vbrk.NETWR', 'Campo valor errado');
  esperar(sql, 'INTERVAL 30 DAY', 'Período errado');
});

testar('Pedidos de compra por fornecedor', () => {
  const sql = buildSQL({
    tabelas: ['EKKO', 'EKPO', 'LFA1'],
    campos:  ['LFA1.NAME1', 'EKPO.MENGE', 'EKPO.NETPR', 'EKKO.BEDAT'],
    joins:   [
      { tabela: 'EKPO', on: 'EKKO.EBELN = EKPO.EBELN' },
      { tabela: 'LFA1', on: 'EKKO.LIFNR = LFA1.LIFNR' },
    ],
    filtros: { periodo_dias: 90, campo_data: 'EKKO.BEDAT' },
    grafico: 'barra',
    eixo_x:  'NAME1',
    eixo_y:  'MENGE',
  });
  esperar(sql, 'sap_lfa1.NAME1', 'Campo fornecedor errado');
  esperar(sql, 'sap_ekpo.MENGE', 'Campo quantidade errado');
  esperar(sql, 'JOIN sap_lfa1 ON sap_ekko.LIFNR = sap_lfa1.LIFNR', 'JOIN LFA1 errado');
});

testar('Notificações de qualidade em aberto', () => {
  const sql = buildSQL({
    tabelas: ['QMEL'],
    campos:  ['QMEL.QMNUM', 'QMEL.MATNR', 'QMEL.QMTXT', 'QMEL.ERDAT', 'QMEL.STAT'],
    joins:   [],
    filtros: { where_extra: "QMEL.STAT = 'OFEN'" },
    grafico: 'pizza',
    eixo_x:  'STAT',
    eixo_y:  'QMNUM',
  });
  esperar(sql, "WHERE sap_qmel.STAT = 'OFEN'", 'Filtro status errado');
});

testar('Estoque atual por material', () => {
  const sql = buildSQL({
    tabelas: ['MARD', 'MARA'],
    campos:  ['MARA.MAKTX', 'MARD.LABST', 'MARD.LGORT'],
    joins:   [{ tabela: 'MARA', on: 'MARD.MATNR = MARA.MATNR' }],
    filtros: {},
    grafico: 'barra',
    eixo_x:  'MAKTX',
    eixo_y:  'LABST',
  });
  esperar(sql, 'JOIN sap_mara ON sap_mard.MATNR = sap_mara.MATNR', 'JOIN MARA errado');
  esperar(sql, 'sap_mara.MAKTX', 'Campo descrição errado');
  esperar(sql, 'sap_mard.LABST', 'Campo estoque errado');
});

testar('Ordens de manutenção por equipamento', () => {
  const sql = buildSQL({
    tabelas: ['AUFK'],
    campos:  ['AUFK.AUFNR', 'AUFK.EQUNR', 'AUFK.AUART', 'AUFK.ERDAT'],
    joins:   [],
    filtros: { periodo_dias: 180, campo_data: 'AUFK.ERDAT' },
    grafico: 'barra',
    eixo_x:  'EQUNR',
    eixo_y:  'AUFNR',
  });
  esperar(sql, 'FROM sap_aufk', 'Tabela errada');
  esperar(sql, 'INTERVAL 180 DAY', 'Período errado');
});

console.log('\n========================\n');