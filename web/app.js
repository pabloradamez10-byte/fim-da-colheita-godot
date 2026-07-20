(() => {
  'use strict';

  const canvas = document.querySelector('#game');
  const ctx = canvas.getContext('2d');
  const status = document.querySelector('#status');
  const toast = document.querySelector('#toast');
  const woodEl = document.querySelector('#wood');
  const stoneEl = document.querySelector('#stone');
  const campfireEl = document.querySelector('#campfire');

  const TILE_W = 64;
  const TILE_H = 32;
  const MAP_W = 32;
  const MAP_H = 32;

  const CHARACTER_FILES = {
    down: './assets/characters/CHR_M_SURVIVOR_0001_S.png',
    right: './assets/characters/CHR_M_SURVIVOR_0001_E.png',
    up: './assets/characters/CHR_M_SURVIVOR_0001_N.png',
    left: './assets/characters/CHR_M_SURVIVOR_0001_W.png'
  };

  const colors = {
    water: '#245d72', wetland: '#4f7055', grass: '#668b4f',
    soil: '#816b48', dry: '#927b58', rock: '#71746e'
  };

  const characterImages = {};
  const loadedDirections = new Set();

  for (const [direction, src] of Object.entries(CHARACTER_FILES)) {
    const image = new Image();
    image.src = src;
    image.addEventListener('load', () => {
      loadedDirections.add(direction);
      if (loadedDirections.size === 4) showToast('Personagem em 4 direções carregado.');
    });
    image.addEventListener('error', () => {
      console.warn('PNG direcional não encontrado:', src);
    });
    characterImages[direction] = image;
  }

  let seed = Number(localStorage.getItem('awe_seed')) || 104729;
  let world = [];
  let objects = [];
  let camera = { x: 0, y: 0 };
  let player = { x: 0, y: 0, wood: 0, stone: 0, campfire: 0, direction: 'down' };

  function mulberry32(a) {
    return function() {
      let t = a += 0x6D2B79F5;
      t = Math.imul(t ^ t >>> 15, t | 1);
      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
  }

  function hashNoise(x, y, s) {
    const n = Math.sin(x * 12.9898 + y * 78.233 + s * 0.001) * 43758.5453;
    return (n - Math.floor(n)) * 2 - 1;
  }

  function smoothNoise(x, y) {
    let total = 0, amp = 1, freq = 0.08, norm = 0;
    for (let o = 0; o < 4; o++) {
      total += hashNoise(x * freq, y * freq, seed + o * 971) * amp;
      norm += amp;
      amp *= 0.5;
      freq *= 2;
    }
    return total / norm;
  }

  function terrainFor(v) {
    if (v < -0.38) return 'water';
    if (v < -0.18) return 'wetland';
    if (v < 0.25) return 'grass';
    if (v < 0.48) return 'soil';
    if (v < 0.67) return 'dry';
    return 'rock';
  }

  function generateWorld() {
    const rnd = mulberry32(seed);
    world = [];
    objects = [];
    for (let y = 0; y < MAP_H; y++) {
      const row = [];
      for (let x = 0; x < MAP_W; x++) {
        const terrain = terrainFor(smoothNoise(x, y));
        row.push(terrain);
        const roll = rnd();
        if (terrain === 'grass' && roll < 0.105) objects.push({ x, y, type: 'tree', alive: true });
        else if ((terrain === 'soil' || terrain === 'dry') && roll < 0.045) objects.push({ x, y, type: 'stone', alive: true });
        else if (terrain === 'wetland' && roll < 0.035) objects.push({ x, y, type: 'bush', alive: true });
      }
      world.push(row);
    }
    player.x = Math.floor(MAP_W / 2);
    player.y = Math.floor(MAP_H / 2);
    player.direction = player.direction || 'down';
    while (world[player.y][player.x] === 'water') player.x++;
    save();
    showToast('Mundo gerado: seed ' + seed);
  }

  function iso(x, y) {
    return { x: (x - y) * TILE_W / 2, y: (x + y) * TILE_H / 2 };
  }

  function resize() {
    const rect = canvas.getBoundingClientRect();
    const dpr = Math.min(devicePixelRatio || 1, 2);
    canvas.width = Math.floor(rect.width * dpr);
    canvas.height = Math.floor(rect.height * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  function drawTile(cx, cy, color) {
    ctx.beginPath();
    ctx.moveTo(cx, cy - TILE_H / 2);
    ctx.lineTo(cx + TILE_W / 2, cy);
    ctx.lineTo(cx, cy + TILE_H / 2);
    ctx.lineTo(cx - TILE_W / 2, cy);
    ctx.closePath();
    ctx.fillStyle = color;
    ctx.fill();
    ctx.strokeStyle = 'rgba(15,25,17,.22)';
    ctx.stroke();
  }

  function drawObject(o, sx, sy) {
    if (!o.alive) return;
    if (o.type === 'tree') {
      ctx.fillStyle = '#5e422d'; ctx.fillRect(sx - 3, sy - 24, 6, 24);
      ctx.fillStyle = '#2e5634'; ctx.beginPath(); ctx.arc(sx, sy - 31, 14, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = '#3f6940'; ctx.beginPath(); ctx.arc(sx - 8, sy - 25, 9, 0, Math.PI * 2); ctx.fill();
    } else if (o.type === 'stone') {
      ctx.fillStyle = '#5d625e'; ctx.beginPath(); ctx.ellipse(sx, sy - 7, 11, 8, -0.2, 0, Math.PI * 2); ctx.fill();
    } else {
      ctx.fillStyle = '#466f43'; ctx.beginPath(); ctx.arc(sx, sy - 7, 8, 0, Math.PI * 2); ctx.fill();
    }
  }

  function drawFallbackPlayer(sx, sy) {
    ctx.fillStyle = '#e6c49b';
    ctx.beginPath(); ctx.arc(sx, sy - 20, 8, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = '#365f42'; ctx.fillRect(sx - 7, sy - 12, 14, 19);
    ctx.strokeStyle = '#232923'; ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(sx - 4, sy + 7); ctx.lineTo(sx - 5, sy + 17);
    ctx.moveTo(sx + 4, sy + 7); ctx.lineTo(sx + 5, sy + 17);
    ctx.stroke();
  }

  function drawPlayer(sx, sy) {
    const image = characterImages[player.direction] || characterImages.down;
    if (!image || !image.complete || image.naturalWidth === 0) return drawFallbackPlayer(sx, sy);

    const drawHeight = 104;
    const drawWidth = drawHeight * (image.naturalWidth / image.naturalHeight);

    ctx.save();
    ctx.imageSmoothingEnabled = true;
    ctx.drawImage(
      image,
      Math.round(sx - drawWidth / 2),
      Math.round(sy - drawHeight + 19),
      Math.round(drawWidth),
      drawHeight
    );
    ctx.restore();
  }

  function render() {
    const w = canvas.clientWidth;
    const h = canvas.clientHeight;
    ctx.clearRect(0, 0, w, h);
    const pIso = iso(player.x, player.y);
    camera.x += ((w / 2) - pIso.x - camera.x) * 0.12;
    camera.y += ((h / 2) - pIso.y - camera.y) * 0.12;

    const drawables = [];
    for (let y = 0; y < MAP_H; y++) {
      for (let x = 0; x < MAP_W; x++) {
        const p = iso(x, y);
        drawTile(p.x + camera.x, p.y + camera.y, colors[world[y][x]]);
      }
    }
    for (const o of objects) if (o.alive) drawables.push({ sort: o.x + o.y, kind: 'object', data: o });
    drawables.push({ sort: player.x + player.y + 0.1, kind: 'player' });
    drawables.sort((a, b) => a.sort - b.sort);
    for (const d of drawables) {
      if (d.kind === 'player') {
        const p = iso(player.x, player.y);
        drawPlayer(p.x + camera.x, p.y + camera.y);
      } else {
        const p = iso(d.data.x, d.data.y);
        drawObject(d.data, p.x + camera.x, p.y + camera.y);
      }
    }
    const spriteState = loadedDirections.size === 4 ? 'personagem 4-dir ativo' : `sprites ${loadedDirections.size}/4`;
    status.textContent = `Seed ${seed} • posição ${player.x},${player.y} • ${spriteState}`;
    requestAnimationFrame(render);
  }

  function canWalk(x, y) {
    return x >= 0 && y >= 0 && x < MAP_W && y < MAP_H && world[y][x] !== 'water';
  }

  function move(dx, dy) {
    if (dx > 0) player.direction = 'right';
    else if (dx < 0) player.direction = 'left';
    else if (dy > 0) player.direction = 'down';
    else if (dy < 0) player.direction = 'up';

    const nx = player.x + dx;
    const ny = player.y + dy;
    if (canWalk(nx, ny)) {
      player.x = nx;
      player.y = ny;
      save();
    } else showToast('Não é possível passar por aqui.');
  }

  function interact() {
    const target = objects.find(o => o.alive && Math.abs(o.x - player.x) + Math.abs(o.y - player.y) <= 1 && (o.type === 'tree' || o.type === 'stone'));
    if (!target) return showToast('Chegue perto de uma árvore ou pedra.');
    target.alive = false;
    if (target.type === 'tree') { player.wood++; showToast('+1 madeira'); }
    else { player.stone++; showToast('+1 pedra'); }
    if (player.wood >= 3 && player.stone >= 2 && player.campfire === 0) {
      player.wood -= 3; player.stone -= 2; player.campfire = 1;
      showToast('🔥 Fogueira criada!');
    }
    updateHud(); save();
  }

  function updateHud() {
    woodEl.textContent = player.wood;
    stoneEl.textContent = player.stone;
    campfireEl.textContent = player.campfire;
  }

  let toastTimer;
  function showToast(text) {
    toast.textContent = text;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('show'), 1400);
  }

  function save() {
    localStorage.setItem('awe_seed', String(seed));
    localStorage.setItem('awe_save', JSON.stringify({ seed, player, objects }));
  }

  function load() {
    try {
      const data = JSON.parse(localStorage.getItem('awe_save'));
      if (!data || data.seed !== seed) return false;
      player = { direction: 'down', ...data.player };
      objects = data.objects;
      return true;
    } catch { return false; }
  }

  const keyMap = {
    ArrowUp: [0,-1], w: [0,-1], W: [0,-1],
    ArrowDown: [0,1], s: [0,1], S: [0,1],
    ArrowLeft: [-1,0], a: [-1,0], A: [-1,0],
    ArrowRight: [1,0], d: [1,0], D: [1,0]
  };

  addEventListener('keydown', e => {
    if (keyMap[e.key]) { e.preventDefault(); move(...keyMap[e.key]); }
    if (e.key === 'e' || e.key === 'E' || e.key === ' ') interact();
  });

  document.querySelectorAll('[data-dir]').forEach(btn => {
    const dirs = { up:[0,-1], down:[0,1], left:[-1,0], right:[1,0] };
    const trigger = e => { e.preventDefault(); move(...dirs[btn.dataset.dir]); };
    btn.addEventListener('pointerdown', trigger);
  });

  document.querySelector('#interact').addEventListener('click', interact);
  document.querySelector('#newWorld').addEventListener('click', () => {
    seed++;
    player = { x: 0, y: 0, wood: 0, stone: 0, campfire: 0, direction: 'down' };
    generateWorld(); updateHud();
  });
  addEventListener('resize', resize);

  resize();
  generateWorld();
  load();
  updateHud();
  requestAnimationFrame(render);
})();