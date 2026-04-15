const sapDictionary = {
  // ── MATERIAIS E ESTOQUE ─────────────────────────────────
  MARA: {
    descricao: "Dados gerais do material",
    palavrasChave: ["material", "produto", "cadastro de material"],
    campos: {
      MATNR: "Código do material",
      MATKL: "Grupo de mercadorias",
      MTART: "Tipo de material",
      MEINS: "Unidade de medida base",
      MAKTX: "Descrição do material",
      NTGEW: "Peso líquido",
      ERSDA: "Data de criação"
    }
  },
  MAKT: {
    descricao: "Descrições de materiais",
    palavrasChave: ["descrição de material", "nome do produto"],
    campos: {
      MATNR: "Código do material",
      SPRAS: "Idioma",
      MAKTX: "Descrição do material"
    }
  },
  MARD: {
    descricao: "Estoque por centro e depósito",
    palavrasChave: ["estoque", "saldo", "quantidade em estoque"],
    campos: {
      MATNR: "Código do material",
      WERKS: "Centro",
      LGORT: "Depósito",
      LABST: "Estoque de uso livre"
    }
  },
  MARC: {
    descricao: "Dados de MRP do material por centro",
    palavrasChave: ["MRP", "planejamento", "estoque mínimo"],
    campos: {
      MATNR: "Código do material",
      WERKS: "Centro",
      DISPO: "Controlador MRP",
      DISMM: "Tipo de MRP",
      MINBE: "Estoque mínimo",
      EISBE: "Estoque de segurança",
      LGPRO: "Depósito de produção"
    }
  },

  // ── MOVIMENTAÇÃO ───────────────────────────────────────
  MSEG: {
    descricao: "Movimentações de estoque",
    palavrasChave: ["movimentação", "entrada", "saída", "transferência"],
    campos: {
      MBLNR: "Número do documento",
      ZEILE: "Item do documento",
      BWART: "Tipo de movimento",
      MATNR: "Código do material",
      WERKS: "Centro",
      LGORT: "Depósito",
      MENGE: "Quantidade",
      DMBTR: "Valor",
      BUDAT: "Data de lançamento"
    }
  },

  // ── PRODUÇÃO ───────────────────────────────────────────
  AFKO: {
    descricao: "Ordens de produção - Cabeçalho",
    palavrasChave: ["ordem de produção", "OP", "produção"],
    campos: {
      AUFNR: "Número da ordem",
      MATNR: "Material produzido",
      WERKS: "Centro",
      GAMNG: "Quantidade planejada",
      GMEIN: "Unidade",
      GSTRI: "Início planejado",
      GETRI: "Fim planejado",
      GSTRS: "Início real",
      GETRS: "Fim real",
      AUFART: "Tipo de ordem"
    }
  },
  AFPO: {
    descricao: "Ordens de produção - Posições",
    palavrasChave: ["posição de produção"],
    campos: {
      AUFNR: "Número da ordem",
      POSNR: "Posição",
      MATNR: "Material",
      PSMNG: "Quantidade planejada",
      WEMNG: "Quantidade entregue"
    }
  },
  AFRU: {
    descricao: "Confirmações de produção",
    palavrasChave: ["confirmação", "apontamento", "produção confirmada"],
    campos: {
      AUFNR: "Ordem",
      RUECK: "Número da confirmação",
      ISMNW: "Quantidade confirmada",
      BUDAT: "Data do apontamento"
    }
  },
  RESB: {
    descricao: "Reservas de componentes",
    palavrasChave: ["reserva", "componente", "necessidade"],
    campos: {
      RSNUM: "Número da reserva",
      AUFNR: "Ordem",
      MATNR: "Material",
      BDMNG: "Quantidade necessária",
      ENMNG: "Quantidade retirada",
      BDTER: "Data de necessidade"
    }
  },

  // ── VENDAS E FATURAMENTO ───────────────────────────────
  VBAK: {
    descricao: "Ordens de venda - Cabeçalho",
    palavrasChave: ["ordem de venda", "pedido de venda", "OV"],
    campos: {
      VBELN: "Número da ordem de venda",
      AUART: "Tipo",
      KUNNR: "Cliente",
      ERDAT: "Data de criação",
      NETWR: "Valor líquido"
    }
  },
  VBRK: {
    descricao: "Faturamento - Cabeçalho",
    palavrasChave: ["faturamento", "nota fiscal", "fatura"],
    campos: {
      VBELN: "Número da fatura",
      FKDAT: "Data da fatura",
      KUNAG: "Cliente",
      NETWR: "Valor líquido",
      MWSBP: "Imposto",
      WAERK: "Moeda"
    }
  },
  VBRP: {
    descricao: "Faturamento - Posições",
    palavrasChave: ["item faturado"],
    campos: {
      VBELN: "Número da fatura",
      MATNR: "Material",
      FKIMG: "Quantidade faturada",
      NETWR: "Valor da posição"
    }
  },

  // ── COMPRAS ─────────────────────────────────────────────
  EKKO: {
    descricao: "Pedidos de compra - Cabeçalho",
    palavrasChave: ["pedido de compra", "PC", "compra"],
    campos: {
      EBELN: "Número do pedido",
      LIFNR: "Fornecedor",
      BEDAT: "Data do pedido"
    }
  },
  EKPO: {
    descricao: "Pedidos de compra - Posições",
    palavrasChave: ["item de compra"],
    campos: {
      EBELN: "Número do pedido",
      MATNR: "Material",
      MENGE: "Quantidade pedida",
      NETPR: "Preço unitário",
      EINDT: "Data de entrega"
    }
  },

  // ── CADASTROS ───────────────────────────────────────────
  KNA1: {
    descricao: "Cadastro de clientes",
    palavrasChave: ["cliente"],
    campos: {
      KUNNR: "Código do cliente",
      NAME1: "Razão social",
      ORT01: "Cidade",
      REGIO: "Estado",
      STCD1: "CNPJ"
    }
  },
  LFA1: {
    descricao: "Cadastro de fornecedores",
    palavrasChave: ["fornecedor"],
    campos: {
      LIFNR: "Código do fornecedor",
      NAME1: "Razão social",
      ORT01: "Cidade",
      REGIO: "Estado"
    }
  },

  // ── MANUTENÇÃO E QUALIDADE ──────────────────────────────
  AUFK: {
    descricao: "Ordens de manutenção",
    palavrasChave: ["ordem de manutenção", "OS"],
    campos: {
      AUFNR: "Número da ordem",
      AUART: "Tipo",
      EQUNR: "Equipamento",
      ERDAT: "Data de criação"
    }
  },
  QMEL: {
    descricao: "Notificações de qualidade",
    palavrasChave: ["qualidade", "não conformidade", "defeito"],
    campos: {
      QMNUM: "Número da notificação",
      MATNR: "Material",
      QMTXT: "Descrição",
      ERDAT: "Data",
      STAT: "Status"
    }
  }
};

function buildDictionaryText() {
  return Object.entries(sapDictionary)
    .map(([tabela, info]) =>
      `Tabela ${tabela}: ${info.descricao}\n` +
      `Campos: ${Object.entries(info.campos).map(([c, d]) => `${c} (${d})`).join(', ')}\n` +
      `Palavras-chave: ${info.palavrasChave.join(', ')}`
    ).join('\n\n');
}

module.exports = { sapDictionary, buildDictionaryText };