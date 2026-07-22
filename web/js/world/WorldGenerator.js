import { terrainForNoise } from '../data/terrainCatalog.js';

export class WorldGenerator {
  constructor(config) {
    this.config = config;
  }

  generate(seed) {
    const random = this.seededRandom(seed);
    const terrain = [];
    const objects = [];

    for (let y = 0; y < this.config.height; y++) {
      const row = [];
      for (let x = 0; x < this.config.width; x++) {
        const terrainId = terrainForNoise(this.smoothNoise(x, y, seed));
        row.push(terrainId);
        this.tryPlaceObject(objects, terrainId, x, y, random());
      }
      terrain.push(row);
    }

    return { terrain, objects };
  }

  findWalkableSpawn(terrain, isWalkable) {
    const startX = Math.floor(this.config.width / 2);
    const startY = Math.floor(this.config.height / 2);
    for (let radius = 0; radius < Math.max(this.config.width, this.config.height); radius++) {
      for (let y = Math.max(0, startY - radius); y <= Math.min(this.config.height - 1, startY + radius); y++) {
        for (let x = Math.max(0, startX - radius); x <= Math.min(this.config.width - 1, startX + radius); x++) {
          if (isWalkable(terrain[y][x])) return { x, y };
        }
      }
    }
    return { x: 0, y: 0 };
  }

  tryPlaceObject(objects, terrainId, x, y, roll) {
    if (terrainId === 'grass' && roll < 0.105) objects.push({ x, y, type: 'tree', alive: true });
    else if ((terrainId === 'soil' || terrainId === 'dry') && roll < 0.045) objects.push({ x, y, type: 'stone', alive: true });
    else if (terrainId === 'wetland' && roll < 0.035) objects.push({ x, y, type: 'bush', alive: true });
  }

  smoothNoise(x, y, seed) {
    let total = 0;
    let amplitude = 1;
    let frequency = 0.08;
    let normalization = 0;
    for (let octave = 0; octave < 4; octave++) {
      total += this.hashNoise(x * frequency, y * frequency, seed + octave * 971) * amplitude;
      normalization += amplitude;
      amplitude *= 0.5;
      frequency *= 2;
    }
    return total / normalization;
  }

  hashNoise(x, y, seed) {
    const value = Math.sin(x * 12.9898 + y * 78.233 + seed * 0.001) * 43758.5453;
    return (value - Math.floor(value)) * 2 - 1;
  }

  seededRandom(initialSeed) {
    let seed = initialSeed;
    return () => {
      let value = seed += 0x6D2B79F5;
      value = Math.imul(value ^ value >>> 15, value | 1);
      value ^= value + Math.imul(value ^ value >>> 7, value | 61);
      return ((value ^ value >>> 14) >>> 0) / 4294967296;
    };
  }
}
