require('dotenv').config();
const db = require('./src/db/connection');

function diasAtras(n) {
  return new Date(Date.now() - n * 86400000).toISOString().split('T')[0];
}

function diasFrente(n) {
  return new Date(Date.now() + n * 86400000).toISOString().split('T')[0];
}

function rand(min, max) {
  return Math.random() * (max - min) + min;
}

function randInt(min, max) {
  return Math.floor(rand(min, max + 1));
}

function pick(arr) {
  return arr[randInt(0, arr.length - 1)];
}

async function seed() {
  console.log('Iniciando seed...\n');

  // ── sap_mara ──────────────────────────────────────────────
  const materiais = [
    ['MAT-001', 'ROL', 'ROH', 'KG',  'Celulose Branqueada Eucalipto', 850.0],
    ['MAT-002', 'ROL', 'ROH', 'KG',  'Celulose Não Branqueada',       780.0],
    ['MAT-003', 'EMB', 'HALB','UN',  'Caixa Papelão Ondulado 30x20',  0.5],
    ['MAT-004', 'EMB', 'HALB','UN',  'Bobina Kraft 80g/m²',           12.0],
    ['MAT-005', 'QUI', 'ROH', 'LT',  'Soda Cáustica 50%',             1.1],
    ['MAT-006', 'QUI', 'ROH', 'KG',  'Dióxido de Cloro',              1.3],
    ['MAT-007', 'EMB', 'FERT','UN',  'Papel Tissue 20x20cm',          0.03],
    ['MAT-008', 'EMB', 'FERT','UN',  'Papel Kraft Industrial 90g',    0.8],
    ['MAT-009', 'ROL', 'ROH', 'M3',  'Madeira Eucalipto Grandis',     600.0],
    ['MAT-010', 'QUI', 'ROH', 'KG',  'Amido de Milho Industrial',     1.4],
    ['MAT-011', 'EMB', 'FERT','UN',  'Saco Multifolhado Válvulado',   0.12],
    ['MAT-012', 'ROL', 'HALB','KG',  'Pasta de Alto Rendimento',      420.0],
  ];

  for (const [MATNR, MATKL, MTART, MEINS, MAKTX, NTGEW] of materiais) {
    await db.query(
      `INSERT IGNORE INTO sap_mara (MATNR,MATKL,MTART,MEINS,MAKTX,NTGEW,ERSDA)
       VALUES (?,?,?,?,?,?,?)`,
      [MATNR, MATKL, MTART, MEINS, MAKTX, NTGEW, '2022-01-01']
    );
  }
  console.log('✔ sap_mara');

  // ── sap_mard ──────────────────────────────────────────────
  const depositos = ['0001','0002','0003','0004'];
  for (const [MATNR] of materiais) {
    const lgort = pick(depositos);
    const labst = parseFloat(rand(500, 50000).toFixed(3));
    await db.query(
      `INSERT IGNORE INTO sap_mard (MATNR,WERKS,LGORT,LABST) VALUES (?,?,?,?)`,
      [MATNR, '1000', lgort, labst]
    );
  }
  console.log('✔ sap_mard');

  // ── sap_mseg ──────────────────────────────────────────────
  const bwarts = ['101','201','261','311','551','601'];
  let mblnr = 5000000001;
  for (let i = 0; i < 200; i++) {
    const mat   = pick(materiais)[0];
    const bwart = pick(bwarts);
    const menge = parseFloat(rand(50, 2000).toFixed(3));
    const dmbtr = parseFloat((menge * rand(5, 30)).toFixed(2));
    const data  = diasAtras(randInt(0, 180));
    const lgort = pick(depositos);
    await db.query(
      `INSERT IGNORE INTO sap_mseg
       (MBLNR,ZEILE,BWART,MATNR,WERKS,LGORT,MENGE,DMBTR,BUDAT)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      [String(mblnr++), '0001', bwart, mat, '1000', lgort, menge, dmbtr, data]
    );
  }
  console.log('✔ sap_mseg');

  // ── sap_kna1 ──────────────────────────────────────────────
  const clientes = [
    ['C-0001','Natura Cosméticos S.A.',      'São Paulo',     'SP','BR','12345678000195'],
    ['C-0002','Ambev S.A.',                  'São Paulo',     'SP','BR','07526557000100'],
    ['C-0003','Magazine Luiza S.A.',         'Franca',        'SP','BR','47960950000121'],
    ['C-0004','JBS S.A.',                    'São Paulo',     'SP','BR','02916265000160'],
    ['C-0005','Embraer S.A.',                'São José dos Campos','SP','BR','07689002000189'],
    ['C-0006','Petrobras Distribuidora',     'Rio de Janeiro','RJ','BR','34274233000102'],
    ['C-0007','Vale S.A.',                   'Rio de Janeiro','RJ','BR','33592510000154'],
    ['C-0008','Grupo Pão de Açúcar',         'São Paulo',     'SP','BR','47508411000156'],
    ['C-0009','Braskem S.A.',                'São Paulo',     'SP','BR','42150391000170'],
    ['C-0010','Suzano S.A.',                 'São Paulo',     'SP','BR','16404287000155'],
    ['C-0011','Votorantim Cimentos',         'São Paulo',     'SP','BR','60047429000122'],
    ['C-0012','Ultrapar Participações',      'São Paulo',     'SP','BR','33256439000139'],
  ];

  for (const [KUNNR, NAME1, ORT01, REGIO, LAND1, STCD1] of clientes) {
    await db.query(
      `INSERT IGNORE INTO sap_kna1 (KUNNR,NAME1,ORT01,REGIO,LAND1,STCD1)
       VALUES (?,?,?,?,?,?)`,
      [KUNNR, NAME1, ORT01, REGIO, LAND1, STCD1]
    );
  }
  console.log('✔ sap_kna1');

  // ── sap_lfa1 ──────────────────────────────────────────────
  const fornecedores = [
    ['F-0001','Arauco Florestal S.A.',      'Curitiba',      'PR','BR','80568835000138'],
    ['F-0002','Imerys Rio Capim Caulim',    'Belém',         'PA','BR','04613975000108'],
    ['F-0003','Basf S.A.',                  'São Paulo',     'SP','BR','48332350000110'],
    ['F-0004','Dow Brasil S.A.',            'São Paulo',     'SP','BR','59145699000188'],
    ['F-0005','3M do Brasil Ltda',          'Sumaré',        'SP','BR','45985371000108'],
    ['F-0006','Evonik Brasil Ltda',         'São Paulo',     'SP','BR','61156942000120'],
    ['F-0007','Clariant S.A.',              'São Paulo',     'SP','BR','61156391000180'],
    ['F-0008','Brenntag Brasil Ltda',       'Guarulhos',     'SP','BR','57538197000147'],
  ];

  for (const [LIFNR, NAME1, ORT01, REGIO, LAND1, STCD1] of fornecedores) {
    await db.query(
      `INSERT IGNORE INTO sap_lfa1 (LIFNR,NAME1,ORT01,REGIO,LAND1,STCD1)
       VALUES (?,?,?,?,?,?)`,
      [LIFNR, NAME1, ORT01, REGIO, LAND1, STCD1]
    );
  }
  console.log('✔ sap_lfa1');

  // ── sap_vbrk + sap_vbrp ───────────────────────────────────
  let vbeln = 9000000001;
  for (let i = 0; i < 150; i++) {
    const cli   = pick(clientes)[0];
    const data  = diasAtras(randInt(0, 180));
    const netwr = parseFloat(rand(3000, 150000).toFixed(2));
    const imposto = parseFloat((netwr * 0.12).toFixed(2));
    await db.query(
      `INSERT IGNORE INTO sap_vbrk
       (VBELN,FKART,FKDAT,KUNAG,NETWR,MWSBP,WAERK,VKORG)
       VALUES (?,?,?,?,?,?,?,?)`,
      [String(vbeln), 'F2', data, cli, netwr, imposto, 'BRL', '1000']
    );
    const mat   = pick(materiais)[0];
    const fkimg = parseFloat(rand(10, 1000).toFixed(3));
    await db.query(
      `INSERT IGNORE INTO sap_vbrp (VBELN,POSNR,MATNR,FKIMG,NETWR,WERKS)
       VALUES (?,?,?,?,?,?)`,
      [String(vbeln), '000010', mat, fkimg, netwr, '1000']
    );
    vbeln++;
  }
  console.log('✔ sap_vbrk + sap_vbrp');

  // ── sap_ekko + sap_ekpo ───────────────────────────────────
  let ebeln = 4500000001;
  for (let i = 0; i < 60; i++) {
    const forn  = pick(fornecedores)[0];
    const data  = diasAtras(randInt(0, 180));
    await db.query(
      `INSERT IGNORE INTO sap_ekko (EBELN,BSART,LIFNR,EKORG,BEDAT,WAERS)
       VALUES (?,?,?,?,?,?)`,
      [String(ebeln), 'NB', forn, '1000', data, 'BRL']
    );
    const mat    = pick(materiais)[0];
    const menge  = parseFloat(rand(100, 5000).toFixed(3));
    const netpr  = parseFloat(rand(5, 80).toFixed(2));
    const entrega = diasFrente(randInt(15, 60));
    await db.query(
      `INSERT IGNORE INTO sap_ekpo
       (EBELN,EBELP,MATNR,WERKS,MENGE,NETPR,WAERS,EINDT)
       VALUES (?,?,?,?,?,?,?,?)`,
      [String(ebeln), '00010', mat, '1000', menge, netpr, 'BRL', entrega]
    );
    ebeln++;
  }
  console.log('✔ sap_ekko + sap_ekpo');

  // ── sap_afko ──────────────────────────────────────────────
  const matsFert = materiais.filter(m => m[2] === 'FERT' || m[2] === 'HALB');
  let aufnrProd = 1000001;
  for (let i = 0; i < 100; i++) {
    const mat    = pick(matsFert)[0];
    const inicio = diasAtras(randInt(10, 180));
    const fim    = diasAtras(randInt(0, 9));
    const gamng  = parseFloat(rand(500, 20000).toFixed(3));
    const aufart = pick(['PP01','PP02','PP03']);
    await db.query(
      `INSERT IGNORE INTO sap_afko
       (AUFNR,MATNR,WERKS,GAMNG,GMEIN,GSTRI,GETRI,GSTRS,GETRS,AUFART)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      [String(aufnrProd++), mat, '1000', gamng, 'KG',
       inicio, fim, inicio, fim, aufart]
    );
  }
  console.log('✔ sap_afko');

  // ── sap_aufk ──────────────────────────────────────────────
  const equipamentos = [
    'EQ-CALDEIRA-01','EQ-BOMBA-02','EQ-COMPRESSOR-03',
    'EQ-LAVADOR-04','EQ-REFINADOR-05','EQ-SECADOR-06',
    'EQ-PICADOR-07','EQ-BOMBA-08',
  ];
  const auarts = ['PM01','PM02','PM03','PM04'];
  const centrosCusto = ['CC-MANUT-01','CC-MANUT-02','CC-UTIL-01'];
  let aufnrManut = 2000001;
  for (let i = 0; i < 50; i++) {
    const data   = diasAtras(randInt(0, 180));
    const auart  = pick(auarts);
    const equip  = pick(equipamentos);
    const kostl  = pick(centrosCusto);
    await db.query(
      `INSERT IGNORE INTO sap_aufk
       (AUFNR,AUART,WERKS,EQUNR,ERDAT,GSTRP,GETRP,KOSTL)
       VALUES (?,?,?,?,?,?,?,?)`,
      [String(aufnrManut++), auart, '1000', equip,
       data, data, diasAtras(randInt(0, 5)), kostl]
    );
  }
  console.log('✔ sap_aufk');

  // ── sap_qmel ──────────────────────────────────────────────
  const defeitos = [
    'Desvio de gramatura',
    'Contaminação por partículas',
    'Umidade fora do padrão',
    'Variação de brilho',
    'Defeito de corte',
    'Resistência abaixo do especificado',
    'Cor fora do padrão',
    'Desvio de espessura',
  ];
  const statuses = ['OFEN','INBE','ABGE'];
  let qmnum = 3000001;
  for (let i = 0; i < 40; i++) {
    const mat  = pick(materiais)[0];
    const data = diasAtras(randInt(0, 180));
    const txt  = pick(defeitos);
    const stat = pick(statuses);
    await db.query(
      `INSERT IGNORE INTO sap_qmel
       (QMNUM,QMART,MATNR,WERKS,QMTXT,ERDAT,STAT)
       VALUES (?,?,?,?,?,?,?)`,
      [String(qmnum++), 'Q1', mat, '1000', txt, data, stat]
    );
  }
  console.log('✔ sap_qmel');

  console.log('\nSeed concluído! Resumo:');
  console.log('  sap_mara:  12 materiais');
  console.log('  sap_mard:  12 registros de estoque');
  console.log('  sap_mseg:  200 movimentações');
  console.log('  sap_kna1:  12 clientes');
  console.log('  sap_lfa1:  8 fornecedores');
  console.log('  sap_vbrk:  150 faturas');
  console.log('  sap_vbrp:  150 posições de fatura');
  console.log('  sap_ekko:  60 pedidos de compra');
  console.log('  sap_ekpo:  60 posições de compra');
  console.log('  sap_afko:  100 ordens de produção');
  console.log('  sap_aufk:  50 ordens de manutenção');
  console.log('  sap_qmel:  40 notificações de qualidade');
  process.exit(0);
}

seed().catch(err => {
  console.error('Erro no seed:', err.message);
  process.exit(1);
});