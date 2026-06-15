const rateLimit = require('express-rate-limit');

// Limita tentativas de login/registro e recuperação de senha para
// dificultar força bruta sobre credenciais e códigos de recuperação.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { erro: 'Muitas tentativas. Tente novamente em alguns minutos.' },
});

module.exports = { authLimiter };
