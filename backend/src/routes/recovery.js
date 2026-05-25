const express = require('express');
const router = express.Router();
const {
  solicitarRecuperacao,
  verificarToken,
  redefinirSenha
} = require('../controllers/recoveryController');

router.post('/solicitar', solicitarRecuperacao); // POST /recovery/solicitar
router.post('/verificar', verificarToken);       // POST /recovery/verificar
router.post('/redefinir', redefinirSenha);       // POST /recovery/redefinir

module.exports = router;