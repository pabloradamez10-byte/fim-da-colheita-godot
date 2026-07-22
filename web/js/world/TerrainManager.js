export class TerrainManager {
  constructor(catalog) {
    this.catalog = new Map(Object.entries(catalog));
  }

  get(terrainId) {
    return this.catalog.get(terrainId) || null;
  }

  isWalkable(terrainId) {
    return this.get(terrainId)?.walkable === true;
  }

  getMovementCost(terrainId) {
    return this.get(terrainId)?.movementCost ?? Infinity;
  }

  getFallbackColor(terrainId) {
    return this.get(terrainId)?.color || '#ff00ff';
  }

  getVariantAssetId(terrainId, x, y, seed) {
    const variants = this.get(terrainId)?.variants || [];
    if (!variants.length) return null;

    const totalWeight = variants.reduce((total, variant) => total + variant.weight, 0);
    let selection = this.stableHash(x, y, seed) % totalWeight;
    for (const variant of variants) {
      if (selection < variant.weight) return variant.assetId;
      selection -= variant.weight;
    }
    return variants[0].assetId;
  }

  stableHash(x, y, seed) {
    let value = Math.imul(x + 374761393, 668265263) ^ Math.imul(y + 1274126177, 2246822519) ^ seed;
    value = Math.imul(value ^ value >>> 13, 1274126177);
    return (value ^ value >>> 16) >>> 0;
  }
}
