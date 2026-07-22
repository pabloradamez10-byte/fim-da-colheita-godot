export const TERRAIN_CATALOG = Object.freeze({
  water: { id: 'water', color: '#245d72', walkable: false },
  wetland: { id: 'wetland', color: '#4f7055', walkable: true },
  grass: { id: 'grass', color: '#668b4f', walkable: true, assetId: 'TERRAIN_GRASS_001' },
  soil: { id: 'soil', color: '#816b48', walkable: true },
  dry: { id: 'dry', color: '#927b58', walkable: true },
  rock: { id: 'rock', color: '#71746e', walkable: true }
});

export function terrainForNoise(value) {
  if (value < -0.38) return 'water';
  if (value < -0.18) return 'wetland';
  if (value < 0.25) return 'grass';
  if (value < 0.48) return 'soil';
  if (value < 0.67) return 'dry';
  return 'rock';
}
