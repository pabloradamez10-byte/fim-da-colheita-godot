import { VERSION, WORLD_CONFIG } from '../config.js';
import { TERRAIN_CATALOG } from '../data/terrainCatalog.js';
import { Player } from '../entities/Player.js';
import { InventorySystem } from '../systems/InventorySystem.js';
import { InteractionSystem } from '../systems/InteractionSystem.js';
import { WorldGenerator } from '../world/WorldGenerator.js';

export class Game {
  constructor({ eventBus, assetManager, saveManager, renderer, elements }) {
    this.eventBus = eventBus;
    this.assetManager = assetManager;
    this.saveManager = saveManager;
    this.renderer = renderer;
    this.elements = elements;
    this.worldGenerator = new WorldGenerator(WORLD_CONFIG);
    this.interactionSystem = new InteractionSystem();
    this.seed = saveManager.loadSeed();
    this.terrain = [];
    this.objects = [];
    this.player = new Player();
    this.inventory = new InventorySystem();
    this.toastTimer = null;
  }

  async start() {
    this.bindEvents();
    this.renderer.resize();
    this.generateWorld(false);
    const saved = this.saveManager.load(this.seed, WORLD_CONFIG);
    if (saved) this.restore(saved);
    else this.save();
    this.updateHud();
    await this.assetManager.loadAll();
    requestAnimationFrame(() => this.renderLoop());
  }

  bindEvents() {
    this.eventBus.on('toast', message => this.showToast(message));
    this.eventBus.on('assets:progress', status => {
      this.elements.status.textContent = `Alpha ${VERSION} • carregando assets ${status.completed}/${status.total}`;
    });
    addEventListener('resize', () => this.renderer.resize());
  }

  generateWorld(persist = true) {
    const generated = this.worldGenerator.generate(this.seed);
    this.terrain = generated.terrain;
    this.objects = generated.objects;
    const spawn = this.worldGenerator.findWalkableSpawn(this.terrain, id => TERRAIN_CATALOG[id]?.walkable);
    this.player.moveTo(spawn.x, spawn.y);
    if (persist) this.save();
    this.eventBus.emit('toast', `Mundo gerado: seed ${this.seed}`);
  }

  newWorld() {
    this.seed++;
    this.player = new Player();
    this.inventory = new InventorySystem();
    this.generateWorld();
    this.updateHud();
  }

  move(dx, dy) {
    this.player.face(dx, dy);
    const x = this.player.x + dx;
    const y = this.player.y + dy;
    if (this.canWalk(x, y)) {
      this.player.moveTo(x, y);
      this.save();
    } else this.eventBus.emit('toast', 'Não é possível passar por aqui.');
  }

  canWalk(x, y) {
    return x >= 0 && y >= 0 && x < WORLD_CONFIG.width && y < WORLD_CONFIG.height &&
      TERRAIN_CATALOG[this.terrain[y][x]]?.walkable;
  }

  interact() {
    const result = this.interactionSystem.interact(this.objects, this.player, this.inventory);
    this.eventBus.emit('toast', result.message);
    if (result.success) {
      this.updateHud();
      this.save();
    }
  }

  save() {
    this.saveManager.save({
      seed: this.seed,
      player: { ...this.player.serialize(), ...this.inventory.serialize() },
      objects: this.objects
    });
  }

  restore(saved) {
    this.player = new Player(saved.player);
    this.inventory = new InventorySystem(saved.player);
    this.objects = saved.objects;
  }

  updateHud() {
    this.elements.wood.textContent = this.inventory.wood;
    this.elements.stone.textContent = this.inventory.stone;
    this.elements.campfire.textContent = this.inventory.campfire;
  }

  showToast(message) {
    this.elements.toast.textContent = message;
    this.elements.toast.classList.add('show');
    clearTimeout(this.toastTimer);
    this.toastTimer = setTimeout(() => this.elements.toast.classList.remove('show'), 1400);
  }

  renderLoop() {
    this.renderer.render(this);
    const assets = this.assetManager.getStatus();
    this.elements.status.textContent = `Alpha ${VERSION} • Seed ${this.seed} • assets ${assets.loaded}/${assets.total}` +
      `${assets.failures ? ` • fallbacks ${assets.failures}` : ''} • posição ${this.player.x},${this.player.y}`;
    requestAnimationFrame(() => this.renderLoop());
  }
}
