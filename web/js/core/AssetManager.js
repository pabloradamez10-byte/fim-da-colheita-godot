export class AssetManager {
  constructor(catalog, eventBus) {
    this.catalog = catalog;
    this.eventBus = eventBus;
    this.images = new Map();
    this.failures = new Set();
  }

  async loadAll() {
    await Promise.all(Object.entries(this.catalog).map(([id, source]) => this.loadImage(id, source)));
    this.eventBus.emit('assets:ready', this.getStatus());
  }

  loadImage(id, source) {
    return new Promise(resolve => {
      const image = new Image();
      image.addEventListener('load', () => {
        this.images.set(id, image);
        resolve(image);
      }, { once: true });
      image.addEventListener('error', () => {
        this.failures.add(id);
        console.error(`Falha ao carregar asset ${id}:`, source);
        resolve(null);
      }, { once: true });
      image.src = source;
    });
  }

  getImage(id) {
    return this.images.get(id) || null;
  }

  getStatus() {
    return {
      loaded: this.images.size,
      total: Object.keys(this.catalog).length,
      failures: this.failures.size
    };
  }
}
