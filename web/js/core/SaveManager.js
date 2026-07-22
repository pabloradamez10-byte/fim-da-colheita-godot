const SEED_KEY = 'awe_seed';
const SAVE_KEY = 'awe_save';
const SAVE_VERSION = 1;

export class SaveManager {
  constructor(eventBus, defaultSeed) {
    this.eventBus = eventBus;
    this.defaultSeed = defaultSeed;
  }

  loadSeed() {
    try {
      return Number(localStorage.getItem(SEED_KEY)) || this.defaultSeed;
    } catch (error) {
      console.warn('Armazenamento local indisponível; usando seed padrão.', error);
      return this.defaultSeed;
    }
  }

  save(state) {
    try {
      localStorage.setItem(SEED_KEY, String(state.seed));
      localStorage.setItem(SAVE_KEY, JSON.stringify({ version: SAVE_VERSION, ...state }));
      return true;
    } catch (error) {
      console.error('Não foi possível salvar o progresso:', error);
      this.eventBus.emit('toast', 'Não foi possível salvar neste navegador.');
      return false;
    }
  }

  load(seed, worldConfig) {
    try {
      const data = JSON.parse(localStorage.getItem(SAVE_KEY));
      if (!this.isValid(data, seed, worldConfig)) return null;
      return data;
    } catch (error) {
      console.warn('Save local inválido; um mundo seguro será iniciado.', error);
      return null;
    }
  }

  isValid(data, seed, worldConfig) {
    const player = data?.player;
    return data?.seed === seed && Array.isArray(data.objects) && player &&
      Number.isInteger(player.x) && Number.isInteger(player.y) &&
      player.x >= 0 && player.y >= 0 &&
      player.x < worldConfig.width && player.y < worldConfig.height;
  }
}
