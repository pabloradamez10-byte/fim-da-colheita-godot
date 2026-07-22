import { ASSET_DEFINITIONS } from './data/assetCatalog.js';
import { TERRAIN_CATALOG } from './data/terrainCatalog.js';
import { ASSET_CACHE_VERSION, WORLD_CONFIG } from './config.js';
import { AssetManager } from './core/AssetManager.js';
import { EventBus } from './core/EventBus.js';
import { Game } from './core/Game.js';
import { InputManager } from './core/InputManager.js';
import { SaveManager } from './core/SaveManager.js';
import { Renderer } from './rendering/Renderer.js';
import { TerrainManager } from './world/TerrainManager.js';

const elements = {
  canvas: document.querySelector('#game'),
  status: document.querySelector('#status'),
  toast: document.querySelector('#toast'),
  wood: document.querySelector('#wood'),
  stone: document.querySelector('#stone'),
  campfire: document.querySelector('#campfire')
};

const eventBus = new EventBus();
const assetManager = new AssetManager({ eventBus, cacheVersion: ASSET_CACHE_VERSION });
assetManager.registerMany(ASSET_DEFINITIONS);
const saveManager = new SaveManager(eventBus, WORLD_CONFIG.defaultSeed);
const terrainManager = new TerrainManager(TERRAIN_CATALOG);
const renderer = new Renderer(elements.canvas, WORLD_CONFIG, assetManager, terrainManager);
const game = new Game({ eventBus, assetManager, saveManager, renderer, terrainManager, elements });

const inputManager = new InputManager({
  onMove: (dx, dy) => game.move(dx, dy),
  onInteract: () => game.interact(),
  onNewWorld: () => game.newWorld()
});

inputManager.bind();
game.start().catch(error => {
  console.error('Falha crítica ao iniciar Fim da Colheita:', error);
  elements.status.textContent = 'Falha ao iniciar o jogo. Recarregue a página.';
});
