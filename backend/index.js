require('dotenv').config(); // carrega o .env — deve ser a primeira linha

const express = require('express');
const cors = require('cors');

const authRoutes    = require('./src/routes/auth');
const scriptRoutes  = require('./src/routes/scripts');
const historyRoutes = require('./src/routes/history');
const recoveryRoutes = require('./src/routes/recovery');
const userRoutes    = require('./src/routes/user');

// JWT_SECRET é exigido por todo o fluxo de autenticação — falhar rápido no
// boot evita tokens assinados/verificados com um segredo vazio/indefinido.
if (!process.env.JWT_SECRET) {
  console.error('JWT_SECRET não definido no .env — encerrando.');
  process.exit(1);
}

const app = express();

// Em produção, defina ALLOWED_ORIGINS no .env (lista separada por vírgulas).
// Sem essa variável, libera qualquer origem — adequado apenas para desenvolvimento.
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',').map(o => o.trim());

if (process.env.NODE_ENV === 'production' && !allowedOrigins) {
  console.error('ALLOWED_ORIGINS não definido em produção — encerrando.');
  process.exit(1);
}

app.use(cors({
  origin: allowedOrigins ?? true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));   // lê JSON no body das requisições

// Rotas
app.use('/auth',    authRoutes);    // POST /auth/register, POST /auth/login
app.use('/api',     scriptRoutes);  // POST /api/gerar-script
app.use('/api',     historyRoutes); // GET  /api/historico, DELETE /api/historico/:id
app.use('/recovery', recoveryRoutes);
app.use('/api',     userRoutes);    // GET /api/perfil, PUT /api/perfil

// Rota de health check — útil pra saber se o servidor está de pé
app.get('/health', (req, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});