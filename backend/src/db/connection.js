const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host:     process.env.DB_HOST,
  port:     parseInt(process.env.DB_PORT),
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
  waitForConnections: true,
  connectionLimit: 10,
});

// Testa a conexão ao iniciar o servidor
pool.getConnection()
  .then(conn => {
    console.log('Conectado ao MySQL (Aiven)');
    conn.release();
  })
  .catch(err => {
    console.error('Erro ao conectar no banco:', err.message);
    process.exit(1); // Para o servidor se não conectar
  });

module.exports = pool;