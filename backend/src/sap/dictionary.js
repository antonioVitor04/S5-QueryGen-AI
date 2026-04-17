const sapDictionary = {

  MARA: {
    tabela_banco: 'sap_mara',
    descricao: "Dados gerais do material",
    palavrasChave: [
      "material", "produto", "cadastro de material", "item",
      "tipo de material", "grupo de mercadorias"
    ],
    campos: {
      MATNR: "Código do material",
      MATKL: "Grupo de mercadorias",
      MTART: "Tipo de material",
      MEINS: "Unidade de medida base",
      MAKTX: "Descrição do material",
      NTGEW: "Peso líquido",
      ERSDA: "Data de criação",
    }
  },

  MARD: {
    tabela_banco: 'sap_mard',
    descricao: "Estoque por centro e depósito",
    palavrasChave: [
      "saldo de estoque", "quantidade em estoque",
      "estoque por depósito", "posição de estoque", "inventário"
    ],
    campos: {
      MATNR: "Código do material",
      WERKS: "Centro",
      LGORT: "Depósito",
      LABST: "Estoque de uso livre",
    }
  },

  MSEG: {
    tabela_banco: 'sap_mseg',
    descricao: "Movimentações de estoque",
    palavrasChave: [
      "movimentação de estoque", "entrada de material", "saída de material",
      "transferência", "consumo", "documento de material", "baixa"
    ],
    campos: {
      MBLNR: "Número do documento de material",
      ZEILE: "Posição do documento",
      BWART: "Tipo de movimento",
      MATNR: "Código do material",
      WERKS: "Centro",
      LGORT: "Depósito",
      MENGE: "Quantidade",
      DMBTR: "Valor em moeda local",
      BUDAT: "Data de lançamento",
    }
  },

  AFKO: {
    tabela_banco: 'sap_afko',
    descricao: "Ordens de produção",
    palavrasChave: [
      "produção", "ordem de produção", "fabricação", "manufatura",
      "OP", "quantidade produzida", "volume de produção"
    ],
    campos: {
      AUFNR: "Número da ordem",
      MATNR: "Código do material",
      WERKS: "Centro produtivo",
      GAMNG: "Quantidade total planejada",
      GMEIN: "Unidade de medida",
      GSTRI: "Data de início planejada",
      GETRI: "Data de fim planejada",
      GSTRS: "Data de início real",
      GETRS: "Data de fim real",
      AUFART: "Tipo de ordem",
    }
  },

  VBRK: {
    tabela_banco: 'sap_vbrk',
    descricao: "Faturamento — cabeçalho da fatura",
    palavrasChave: [
      "faturamento", "nota fiscal", "receita", "invoice",
      "fatura", "valor faturado", "vendas"
    ],
    campos: {
      VBELN: "Número da fatura",
      FKART: "Tipo de fatura",
      FKDAT: "Data da fatura",
      KUNAG: "Código do cliente",
      NETWR: "Valor líquido",
      MWSBP: "Valor do imposto",
      WAERK: "Moeda",
      VKORG: "Organização de vendas",
    }
  },

  VBRP: {
    tabela_banco: 'sap_vbrp',
    descricao: "Faturamento — posições da fatura",
    palavrasChave: [
      "posição de fatura", "item faturado", "produto vendido",
      "quantidade faturada", "valor por item"
    ],
    campos: {
      VBELN: "Número da fatura",
      POSNR: "Posição",
      MATNR: "Código do material",
      FKIMG: "Quantidade faturada",
      NETWR: "Valor líquido da posição",
      WERKS: "Centro",
    }
  },

  EKKO: {
    tabela_banco: 'sap_ekko',
    descricao: "Pedidos de compra — cabeçalho",
    palavrasChave: [
      "pedido de compra", "PC", "purchase order", "PO",
      "compra", "aquisição", "ordem de compra"
    ],
    campos: {
      EBELN: "Número do pedido de compra",
      BSART: "Tipo de documento de compras",
      LIFNR: "Código do fornecedor",
      EKORG: "Organização de compras",
      BEDAT: "Data do pedido",
      WAERS: "Moeda",
    }
  },

  EKPO: {
    tabela_banco: 'sap_ekpo',
    descricao: "Pedidos de compra — posições",
    palavrasChave: [
      "posição de compra", "item de compra", "material comprado",
      "fornecedor", "preço de compra", "quantidade comprada"
    ],
    campos: {
      EBELN: "Número do pedido",
      EBELP: "Posição do pedido",
      MATNR: "Código do material",
      WERKS: "Centro",
      MENGE: "Quantidade do pedido",
      NETPR: "Preço líquido",
      WAERS: "Moeda",
      EINDT: "Data de entrega",
    }
  },

  KNA1: {
    tabela_banco: 'sap_kna1',
    descricao: "Cadastro de clientes",
    palavrasChave: [
      "cliente", "customer", "razão social cliente",
      "cadastro cliente", "comprador"
    ],
    campos: {
      KUNNR: "Código do cliente",
      NAME1: "Nome/Razão social",
      ORT01: "Cidade",
      REGIO: "Estado",
      LAND1: "País",
      STCD1: "CNPJ/CPF",
    }
  },

  LFA1: {
    tabela_banco: 'sap_lfa1',
    descricao: "Cadastro de fornecedores",
    palavrasChave: [
      "fornecedor", "vendor", "supplier",
      "cadastro fornecedor", "parceiro de compras"
    ],
    campos: {
      LIFNR: "Código do fornecedor",
      NAME1: "Nome/Razão social",
      ORT01: "Cidade",
      REGIO: "Estado",
      LAND1: "País",
      STCD1: "CNPJ/CPF",
    }
  },

  AUFK: {
    tabela_banco: 'sap_aufk',
    descricao: "Ordens de manutenção",
    palavrasChave: [
      "manutenção", "ordem de manutenção", "OS", "equipamento",
      "manutenção corretiva", "manutenção preventiva", "PM"
    ],
    campos: {
      AUFNR: "Número da ordem",
      AUART: "Tipo de ordem",
      WERKS: "Centro",
      EQUNR: "Equipamento",
      ERDAT: "Data de criação",
      GSTRP: "Data início planejada",
      GETRP: "Data fim planejada",
      KOSTL: "Centro de custo",
    }
  },

  QMEL: {
    tabela_banco: 'sap_qmel',
    descricao: "Notificações de qualidade",
    palavrasChave: [
      "qualidade", "defeito", "notificação de qualidade",
      "não conformidade", "QM", "inspeção", "reclamação"
    ],
    campos: {
      QMNUM: "Número da notificação",
      QMART: "Tipo de notificação",
      MATNR: "Material",
      WERKS: "Centro",
      QMTXT: "Descrição do defeito",
      ERDAT: "Data de criação",
      STAT:  "Status",
    }
  },

};

function buildDictionaryText() {
  return Object.entries(sapDictionary)
    .map(([tabela, info]) =>
      `Tabela ${tabela} (banco: ${info.tabela_banco}): ${info.descricao}\n` +
      `  Campos disponíveis: ${Object.entries(info.campos)
        .map(([c, d]) => `${c} (${d})`).join(', ')}\n` +
      `  Palavras-chave: ${info.palavrasChave.join(', ')}`
    ).join('\n\n');
}

// Retorna o nome real da tabela no banco a partir do nome SAP
function getTabelaBanco(tabelaSAP) {
  return sapDictionary[tabelaSAP]?.tabela_banco ?? null;
}

module.exports = { sapDictionary, buildDictionaryText, getTabelaBanco };