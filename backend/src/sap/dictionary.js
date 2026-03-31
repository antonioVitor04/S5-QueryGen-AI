// backend/src/sap/dictionary.js
const sapDictionary = {
  AFKO: {
    descricao: "Ordens de produção (cabeçalho)",
    palavrasChave: ["produção", "ordem", "fabricação", "manufatura"],
    campos: {
      AUFNR: "Número da ordem",
      GAMNG: "Quantidade total planejada",
      GSTRI: "Data de início",
      GETRI: "Data de fim",
      MATNR: "Código do material"
    }
  },
  VBRK: {
    descricao: "Faturamento (cabeçalho da fatura)",
    palavrasChave: ["faturamento", "nota fiscal", "receita", "vendas"],
    campos: {
      VBELN: "Número da fatura",
      NETWR: "Valor líquido",
      FKDAT: "Data da fatura",
      KUNAG: "Cliente"
    }
  },
  MSEG: {
    descricao: "Movimentações de estoque",
    palavrasChave: ["estoque", "material", "movimentação", "entrada", "saída"],
    campos: {
      MATNR: "Código do material",
      MENGE: "Quantidade",
      BLDAT: "Data do documento",
      BWART: "Tipo de movimento"
    }
  },
  EKPO: {
    descricao: "Itens de pedido de compra",
    palavrasChave: ["compra", "pedido", "fornecedor", "aquisição"],
    campos: {
      EBELN: "Número do pedido",
      MATNR: "Código do material",
      MENGE: "Quantidade",
      NETPR: "Preço líquido",
      BEDAT: "Data do pedido"
    }
  }
};

// Gera o texto do dicionário para injetar no prompt
function buildDictionaryText() {
  return Object.entries(sapDictionary)
    .map(([tabela, info]) =>
      `${tabela}: ${info.descricao}\n` +
      `  Campos: ${Object.keys(info.campos).join(', ')}\n` +
      `  Palavras-chave: ${info.palavrasChave.join(', ')}`
    ).join('\n\n');
}

module.exports = { sapDictionary, buildDictionaryText };