const express = require('express');
const router = express.Router();
const {
  solicitarRecuperacao,
  verificarToken,
  redefinirSenha
} = require('../controllers/recoveryController');
const { authLimiter } = require('../middleware/rateLimiter');

router.post('/solicitar', authLimiter, solicitarRecuperacao); // POST /recovery/solicitar
router.post('/verificar', authLimiter, verificarToken);       // POST /recovery/verificar
router.post('/redefinir', authLimiter, redefinirSenha);       // POST /recovery/redefinir

module.exports = router;