/**
 * QueryGen AI — Plugin de Acessibilidade
 */

(function () {
  'use strict';

  /* ─────────────── ESTADO GLOBAL ─────────────── */
  let ttsAtivo       = false;
  let voz            = null;
  let velocidade     = 1.0;
  let volume         = 1.0;
  let painelAberto   = false;
  let destacandoEl   = null;
  let modoClique     = false;
  let textoAtual     = '';   // guarda o texto em leitura (para reiniciar ao trocar velocidade/volume)

  /* ─────────────── ESTILOS ─────────────── */
  const style = document.createElement('style');
  style.textContent = `
    #acc-fab {
      position: fixed; bottom: 24px; right: 24px;
      width: 56px; height: 56px; border-radius: 50%;
      background: #1565C0; color: #fff; border: none;
      cursor: pointer; font-size: 24px;
      display: flex; align-items: center; justify-content: center;
      box-shadow: 0 4px 16px rgba(0,0,0,0.28);
      z-index: 99998; transition: background 0.2s, transform 0.15s; outline: none;
    }
    #acc-fab:hover { background: #0D47A1; transform: scale(1.07); }
    #acc-fab:focus-visible { outline: 3px solid #FFD600; outline-offset: 3px; }

    #acc-painel {
      position: fixed; bottom: 90px; right: 24px; width: 320px;
      background: #fff; border-radius: 16px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.22);
      z-index: 99997; font-family: system-ui, sans-serif;
      overflow: hidden; transition: opacity 0.2s, transform 0.2s;
      opacity: 0; transform: translateY(12px) scale(0.97); pointer-events: none;
    }
    #acc-painel.aberto { opacity: 1; transform: none; pointer-events: auto; }

    #acc-header {
      background: #1565C0; color: #fff;
      padding: 14px 18px; font-size: 15px; font-weight: 600;
      display: flex; align-items: center; gap: 10px;
    }
    #acc-body { padding: 16px 18px; }
    .acc-secao { margin-bottom: 18px; }
    .acc-secao-titulo {
      font-size: 11px; font-weight: 600; letter-spacing: 0.08em;
      text-transform: uppercase; color: #78909C; margin-bottom: 10px;
    }
    .acc-btn-grupo { display: flex; gap: 8px; flex-wrap: wrap; }
    .acc-btn {
      flex: 1 1 auto; padding: 9px 12px; border-radius: 8px;
      border: 1.5px solid #BBDEFB; background: #E3F2FD; color: #1565C0;
      font-size: 13px; font-weight: 500; cursor: pointer;
      display: flex; align-items: center; gap: 6px; justify-content: center;
      transition: background 0.15s, border-color 0.15s;
      outline: none; white-space: nowrap;
    }
    .acc-btn:hover { background: #BBDEFB; border-color: #1565C0; }
    .acc-btn:focus-visible { outline: 3px solid #FFD600; }
    .acc-btn.ativo { background: #1565C0; color: #fff; border-color: #1565C0; }
    .acc-btn.ativo:hover { background: #0D47A1; }
    .acc-btn.perigo { border-color: #FFCDD2; background: #FFEBEE; color: #C62828; }
    .acc-btn.perigo:hover { background: #FFCDD2; }
    .acc-btn:disabled { opacity: 0.45; cursor: not-allowed; }
    .acc-slider-linha {
      display: flex; align-items: center; gap: 10px; margin-bottom: 10px;
    }
    .acc-slider-label { font-size: 12px; color: #455A64; min-width: 72px; }
    .acc-slider-valor { font-size: 12px; font-weight: 600; color: #1565C0; min-width: 32px; text-align: right; }
    .acc-slider-linha input[type=range] { flex: 1; accent-color: #1565C0; }
    .acc-divisor { border: none; border-top: 1px solid #ECEFF1; margin: 14px 0; }
    .acc-status {
      font-size: 12px; color: #455A64; text-align: center;
      padding: 6px; background: #F5F5F5; border-radius: 8px;
      min-height: 32px; display: flex; align-items: center; justify-content: center;
    }
    .acc-lendo {
      outline: 3px solid #FFD600 !important;
      outline-offset: 2px !important;
      background-color: rgba(255,214,0,0.18) !important;
      border-radius: 3px !important;
    }
  `;
  document.head.appendChild(style);

  /* ─────────────── HTML DO PAINEL ─────────────── */
  const painel = document.createElement('div');
  painel.id = 'acc-painel';
  painel.setAttribute('role', 'dialog');
  painel.setAttribute('aria-modal', 'false');
  painel.setAttribute('aria-label', 'Painel de acessibilidade');
  painel.innerHTML = `
    <div id="acc-header" role="heading" aria-level="2">
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" aria-hidden="true">
        <circle cx="12" cy="12" r="10"/>
        <path d="M12 8v4l3 3"/>
      </svg>
      Acessibilidade
    </div>
    <div id="acc-body">
      <div class="acc-secao">
        <div class="acc-secao-titulo">Leitura em voz alta</div>
        <div class="acc-btn-grupo" style="margin-bottom:10px;">
          <button class="acc-btn" id="acc-ler-pagina" aria-label="Ler toda a página em voz alta">Ler página</button>
          <button class="acc-btn" id="acc-pausar" aria-label="Pausar leitura" disabled>Pausar</button>
          <button class="acc-btn perigo" id="acc-parar" aria-label="Parar leitura" disabled>Parar</button>
        </div>
        <div class="acc-btn-grupo" style="margin-bottom:10px;">
          <button class="acc-btn" id="acc-modo-clique" title="Clique em qualquer texto da página para ouvi-lo">
            Ler ao clicar
          </button>
        </div>
        <div class="acc-slider-linha">
          <span class="acc-slider-label">Velocidade</span>
          <input type="range" min="0.5" max="2" step="0.1" value="1.0" id="acc-velocidade" aria-label="Velocidade da voz">
          <span class="acc-slider-valor" id="acc-velocidade-val">1.0x</span>
        </div>
        <div class="acc-slider-linha">
          <span class="acc-slider-label">Volume</span>
          <input type="range" min="0" max="1" step="0.1" value="1.0" id="acc-volume" aria-label="Volume da voz">
          <span class="acc-slider-valor" id="acc-volume-val">100%</span>
        </div>
      </div>

      <hr class="acc-divisor">

      <div class="acc-secao">
        <div class="acc-secao-titulo">Lingua de sinais (LIBRAS)</div>
        <div class="acc-btn-grupo">
          <button class="acc-btn" id="acc-vlibras" aria-label="Ativar o tradutor de Libras VLibras">
            Ativar VLibras
          </button>
        </div>
        <p style="font-size:11px; color:#78909C; margin-top:8px; line-height:1.5;">
          O VLibras e o tradutor oficial de Libras do governo federal.
        </p>
      </div>

      <hr class="acc-divisor">

      <div class="acc-status" id="acc-status" aria-live="polite" aria-atomic="true">
        Pronto para leitura
      </div>
    </div>
  `;
  document.body.appendChild(painel);

  const fab = document.createElement('button');
  fab.id = 'acc-fab';
  fab.setAttribute('aria-label', 'Abrir painel de acessibilidade');
  fab.setAttribute('aria-expanded', 'false');
  fab.innerHTML = `
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
      <circle cx="12" cy="4" r="2"/>
      <path d="M19 9H5l2 10h10l2-10zM12 10v9M9 13H7M17 13h-2"/>
    </svg>`;
  document.body.appendChild(fab);

  /* ─────────────── FILTRO DE CÓDIGO INTERNO ─────────────── */
  // Descarta apenas o que claramente é código Dart/Flutter — não filtra UI em português
  function pareceCodigoInterno(texto) {
    const t = texto.trim();
    if (t.length < 2) return true;
    // Classes/tipos Flutter/Dart
    if (/\b(Widget|BuildContext|StatefulWidget|StatelessWidget|EdgeInsets|BoxDecoration)\b/.test(t)) return true;
    // Palavras-chave de código sem contexto
    if (/^(import|export|class|void|final|const|return|async|await)\s/.test(t)) return true;
    // Comentário de código
    if (/^\s*\/\//.test(t)) return true;
    // Referência de objeto (camelCase.método, sem espaços)
    if (/^[a-z][a-zA-Z0-9]+\.[a-zA-Z]/.test(t) && !/\s/.test(t)) return true;
    // Hex puro
    if (/^0x[0-9a-fA-F]+$/.test(t)) return true;
    // Linha começa com chave ou colchete (bloco de código)
    if (/^[{[\(]/.test(t) && t.length < 8) return true;
    return false;
  }

  /* ─────────────── COLETA DE TEXTO DA PÁGINA ─────────────── */
  function coletarTextoPagina() {
    // Esconde temporariamente elementos que não são conteúdo visual da app.
    // innerText respeita visibility:hidden — elementos ocultos são excluídos do resultado.
    // A operação é síncrona, sem repaint visível.
    const excluir = [
      ...document.querySelectorAll(
        '#acc-painel, #acc-fab, flt-semantics-placeholder, flt-announcement'
      )
    ];
    excluir.forEach(el => { el._vis = el.style.visibility; el.style.visibility = 'hidden'; });

    const raw = document.body.innerText || '';

    excluir.forEach(el => { el.style.visibility = el._vis ?? ''; delete el._vis; });

    if (!raw.trim()) return '';

    const seen = new Set();
    const linhas = raw
      .split(/[\n\r\t]+/)
      .map(l => l.trim())
      .filter(l => l.length > 1)
      .filter(l => !/enable\s+(accessibility|access)/i.test(l))
      .filter(l => !pareceCodigoInterno(l))
      .filter(l => seen.has(l) ? false : seen.add(l));

    return linhas.join('. ');
  }

  /* ─────────────── TTS ─────────────── */
  function setStatus(msg) {
    const el = document.getElementById('acc-status');
    if (el) el.textContent = msg;
  }

  function carregarVoz() {
    const vozes = window.speechSynthesis.getVoices();
    voz = vozes.find(v => v.lang === 'pt-BR') ||
          vozes.find(v => v.lang.startsWith('pt')) ||
          vozes[0] || null;
  }
  if (window.speechSynthesis) {
    window.speechSynthesis.onvoiceschanged = carregarVoz;
    carregarVoz();
  }

  function falar(texto, onEnd) {
    if (!window.speechSynthesis) { setStatus('Navegador sem suporte a voz.'); return; }
    textoAtual = texto;
    window.speechSynthesis.cancel();
    const utt = new SpeechSynthesisUtterance(texto);
    utt.lang   = 'pt-BR';
    utt.rate   = velocidade;
    utt.volume = volume;
    if (voz) utt.voice = voz;
    utt.onstart = () => { ttsAtivo = true;  setStatus('Lendo...'); atualizarBotoes(); };
    utt.onend   = () => {
      ttsAtivo = false; textoAtual = ''; removerDestaque();
      setStatus('Leitura concluida'); atualizarBotoes();
      if (onEnd) onEnd();
    };
    utt.onerror = (e) => {
      if (e.error !== 'interrupted') setStatus('Erro: ' + e.error);
      ttsAtivo = false; atualizarBotoes();
    };
    window.speechSynthesis.speak(utt);
  }

  function removerDestaque() {
    if (destacandoEl) { destacandoEl.classList.remove('acc-lendo'); destacandoEl = null; }
  }

  function atualizarBotoes() {
    const btnPausar = document.getElementById('acc-pausar');
    const btnParar  = document.getElementById('acc-parar');
    if (btnPausar) {
      btnPausar.disabled    = !ttsAtivo;
      btnPausar.textContent = window.speechSynthesis.paused ? 'Retomar' : 'Pausar';
    }
    if (btnParar) btnParar.disabled = !ttsAtivo;
  }

  /* ─────────────── MODO CLIQUE ─────────────── */
  function ativarModoClique() {
    modoClique = !modoClique;
    const btn = document.getElementById('acc-modo-clique');
    if (btn) {
      btn.classList.toggle('ativo', modoClique);
      btn.textContent = modoClique ? 'Modo clique ativo' : 'Ler ao clicar';
    }
    document.body.style.cursor = modoClique ? 'context-menu' : '';
    setStatus(modoClique ? 'Clique com o botao direito em qualquer texto.' : 'Modo clique desativado.');
    if (modoClique) {
      document.addEventListener('contextmenu', handleCliqueNaPagina, true);
    } else {
      document.removeEventListener('contextmenu', handleCliqueNaPagina, true);
    }
  }

  function handleCliqueNaPagina(e) {
    if (e.target.closest('#acc-painel') || e.target.closest('#acc-fab')) return;
    // Suprime o menu de contexto do navegador
    e.preventDefault();
    e.stopPropagation();

    let el    = e.target;
    let texto = '';

    // Sobe até 10 níveis procurando texto legível
    for (let i = 0; i < 10; i++) {
      if (!el || el === document.body) break;

      // 1. aria-label tem prioridade se não parecer código
      const aria = el.getAttribute('aria-label');
      if (aria && aria.trim().length > 2 && !pareceCodigoInterno(aria)) {
        texto = aria.trim();
        break;
      }

      // 2. innerText direto (sem filhos) — evita concatenar todo o subtree
      const direto = Array.from(el.childNodes)
        .filter(n => n.nodeType === Node.TEXT_NODE)
        .map(n => n.textContent.trim())
        .filter(t => t.length > 0)
        .join(' ');
      if (direto.length > 2 && !pareceCodigoInterno(direto)) {
        texto = direto;
        break;
      }

      // 3. innerText completo como fallback
      const inner = (el.innerText || '').trim();
      if (inner.length > 2 && inner.length < 500 && !pareceCodigoInterno(inner)) {
        texto = inner;
        break;
      }

      el = el.parentElement;
    }

    if (!texto) { setStatus('Nenhum texto encontrado nesse elemento.'); return; }

    removerDestaque();
    if (el && el !== document.body) {
      el.classList.add('acc-lendo');
      destacandoEl = el;
    }
    falar(texto);
  }

  /* ─────────────── VLIBRAS ─────────────── */
  let vlibrasAtivo = false;
  function ativarVLibras() {
    if (vlibrasAtivo) { setStatus('VLibras ja esta ativo.'); return; }
    vlibrasAtivo = true;
    const btn = document.getElementById('acc-vlibras');
    if (btn) { btn.textContent = 'VLibras ativo'; btn.classList.add('ativo'); }

    const div = document.createElement('div');
    div.setAttribute('vw', '');
    div.className = 'enabled';
    div.innerHTML = `
      <div vw-access-button class="active"></div>
      <div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div>`;
    document.body.appendChild(div);

    const s = document.createElement('script');
    s.src = 'https://vlibras.gov.br/app/vlibras-plugin.js';
    s.onload = () => {
      try {
        new window.VLibras.Widget('https://vlibras.gov.br/app');
        setStatus('VLibras iniciado. Clique no icone azul.');
      } catch (e) { setStatus('Erro ao iniciar VLibras.'); }
    };
    s.onerror = () => setStatus('VLibras indisponivel (sem internet?).');
    document.body.appendChild(s);
  }

  /* ─────────────── EVENTOS DO PAINEL ─────────────── */
  fab.addEventListener('click', () => {
    painelAberto = !painelAberto;
    painel.classList.toggle('aberto', painelAberto);
    fab.setAttribute('aria-expanded', String(painelAberto));
    if (painelAberto) painel.querySelector('button')?.focus();
  });

  document.addEventListener('keydown', (e) => {
    if (e.altKey && e.key === 'a') fab.click();
    if (e.key === 'Escape' && painelAberto) {
      painelAberto = false;
      painel.classList.remove('aberto');
      fab.setAttribute('aria-expanded', 'false');
      fab.focus();
    }
  });

  painel.addEventListener('click', (e) => {
    const id = e.target.closest('button')?.id;
    if (!id) return;

    if (id === 'acc-ler-pagina') {
      // Cancela qualquer fala anterior ANTES de verificar o texto da página
      window.speechSynthesis.cancel();
      textoAtual = '';
      removerDestaque();
      const texto = coletarTextoPagina();
      if (!texto) { setStatus('Nenhum texto encontrado na pagina.'); return; }
      falar(texto);
    }
    if (id === 'acc-pausar') {
      if (window.speechSynthesis.paused) {
        window.speechSynthesis.resume(); setStatus('Continuando leitura...');
      } else {
        window.speechSynthesis.pause(); setStatus('Pausado');
      }
      atualizarBotoes();
    }
    if (id === 'acc-parar') {
      window.speechSynthesis.cancel();
      removerDestaque(); ttsAtivo = false; textoAtual = '';
      setStatus('Leitura interrompida'); atualizarBotoes();
    }
    if (id === 'acc-modo-clique') ativarModoClique();
    if (id === 'acc-vlibras')     ativarVLibras();
  });

  /* ─────────────── SLIDERS ─────────────── */
  const slVel    = document.getElementById('acc-velocidade');
  const slVelVal = document.getElementById('acc-velocidade-val');
  if (slVel) {
    slVel.addEventListener('input', () => {
      velocidade = parseFloat(slVel.value);
      slVelVal.textContent = velocidade.toFixed(1) + 'x';
      // Reinicia a leitura em andamento com a nova velocidade
      if (ttsAtivo && textoAtual) {
        const txt = textoAtual;
        window.speechSynthesis.cancel();
        setTimeout(() => falar(txt), 80);
      }
    });
  }

  const slVol    = document.getElementById('acc-volume');
  const slVolVal = document.getElementById('acc-volume-val');
  if (slVol) {
    slVol.addEventListener('input', () => {
      volume = parseFloat(slVol.value);
      slVolVal.textContent = Math.round(volume * 100) + '%';
      // Reinicia a leitura em andamento com o novo volume
      if (ttsAtivo && textoAtual) {
        const txt = textoAtual;
        window.speechSynthesis.cancel();
        setTimeout(() => falar(txt), 80);
      }
    });
  }

  console.log('[Acessibilidade] Plugin carregado. Atalho: Alt+A');
})();
