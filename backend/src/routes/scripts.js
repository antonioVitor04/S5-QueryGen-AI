const express = require('express');
const router = express.Router();
const { gerarScript } = require('../controllers/scriptController');
const authMiddleware = require('../middleware/auth');

// authMiddleware garante que só usuários logados acessam
router.post('/gerar-script', authMiddleware, gerarScript);

module.exports = router;