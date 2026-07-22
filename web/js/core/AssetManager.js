const SUPPORTED_TYPES = new Set(['image', 'json', 'audio']);

export class AssetManager {
  constructor({ eventBus, cacheVersion = '' }) {
    this.eventBus = eventBus;
    this.cacheVersion = cacheVersion;
    this.registry = new Map();
    this.resources = new Map();
    this.inflight = new Map();
    this.failures = new Map();
  }

  register(definition) {
    this.validateDefinition(definition);
    if (this.registry.has(definition.id)) return false;
    this.registry.set(definition.id, Object.freeze({ cacheBust: true, ...definition }));
    return true;
  }

  registerMany(definitions) {
    for (const definition of definitions) this.register(definition);
    return this;
  }

  async loadAll(assetIds = [...this.registry.keys()]) {
    this.emitProgress();
    await Promise.all(assetIds.map(assetId => this.load(assetId)));
    const status = this.getStatus();
    this.eventBus.emit('assets:ready', status);
    return status;
  }

  load(assetId) {
    if (this.resources.has(assetId)) return Promise.resolve(this.resources.get(assetId));
    if (this.inflight.has(assetId)) return this.inflight.get(assetId);

    const definition = this.registry.get(assetId);
    if (!definition) return Promise.reject(new Error(`Asset não registrado: ${assetId}`));

    const request = this.loadDefinition(definition)
      .then(resource => {
        this.resources.set(assetId, resource);
        this.failures.delete(assetId);
        return resource;
      })
      .catch(error => {
        this.failures.set(assetId, error);
        console.error(`Falha ao carregar asset ${assetId}:`, definition.path, error);
        return null;
      })
      .finally(() => {
        this.inflight.delete(assetId);
        this.emitProgress();
      });

    this.inflight.set(assetId, request);
    return request;
  }

  loadDefinition(definition) {
    const source = this.resolvePath(definition);
    if (definition.type === 'image') return this.loadImage(source);
    if (definition.type === 'json') return this.loadJson(source);
    return this.loadAudio(source);
  }

  loadImage(source) {
    return new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener('load', () => resolve(image), { once: true });
      image.addEventListener('error', () => reject(new Error('Imagem indisponível')), { once: true });
      image.src = source;
    });
  }

  async loadJson(source) {
    const response = await fetch(source);
    if (!response.ok) throw new Error(`JSON indisponível: HTTP ${response.status}`);
    return response.json();
  }

  loadAudio(source) {
    return new Promise((resolve, reject) => {
      const audio = new Audio();
      audio.preload = 'auto';
      audio.addEventListener('canplaythrough', () => resolve(audio), { once: true });
      audio.addEventListener('error', () => reject(new Error('Áudio indisponível')), { once: true });
      audio.src = source;
      audio.load();
    });
  }

  resolvePath(definition) {
    if (!definition.cacheBust || !this.cacheVersion) return definition.path;
    const separator = definition.path.includes('?') ? '&' : '?';
    return `${definition.path}${separator}v=${encodeURIComponent(definition.version || this.cacheVersion)}`;
  }

  get(assetId) {
    return this.resources.get(assetId) || null;
  }

  getImage(assetId) {
    const definition = this.registry.get(assetId);
    return definition?.type === 'image' ? this.get(assetId) : null;
  }

  hasFailed(assetId) {
    return this.failures.has(assetId);
  }

  getStatus() {
    const total = this.registry.size;
    const loaded = this.resources.size;
    const failures = this.failures.size;
    return { loaded, failures, completed: loaded + failures, total };
  }

  emitProgress() {
    this.eventBus.emit('assets:progress', this.getStatus());
  }

  validateDefinition(definition) {
    if (!definition?.id || !definition?.path || !SUPPORTED_TYPES.has(definition.type)) {
      throw new TypeError('Definição de asset inválida. Use id, type e path.');
    }
  }
}
