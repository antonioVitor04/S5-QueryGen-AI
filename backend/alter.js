require('dotenv').config();
const db = require('./src/db/connection');

async function alter() {
  await db.query(`
    ALTER TABLE historico
      ADD COLUMN grafico   VARCHAR(10)  NULL,
      ADD COLUMN eixo_x    VARCHAR(50)  NULL,
      ADD COLUMN eixo_y    VARCHAR(50)  NULL,
      ADD COLUMN descricao VARCHAR(255) NULL
  `);
  console.log('Colunas adicionadas com sucesso!');
  process.exit(0);
}

alter().catch(err => {
  console.error('Erro:', err.message);
  process.exit(1);
});