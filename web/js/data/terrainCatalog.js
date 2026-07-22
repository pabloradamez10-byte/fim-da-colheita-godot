export const TERRAIN_CATALOG = Object.freeze({
  water: {
    id: 'water', name: 'Água profunda', color: '#245d72', walkable: false, movementCost: Infinity, variants: []
  },
  wetland: {
    id: 'wetland', name: 'Área alagada', color: '#4f7055', walkable: true, movementCost: 1.5, variants: []
  },
  grass: {
    id: 'grass',
    name: 'Grama',
    color: '#668b4f',
    walkable: true,
    movementCost: 1,
    variants: [
      { assetId: 'TERRAIN_GRASS_001', weight: 30 },
      { assetId: 'TERRAIN_GRASS_002', weight: 24 },
      { assetId: 'TERRAIN_GRASS_003', weight: 16 },
      { assetId: 'TERRAIN_GRASS_FLOWERS_001', weight: 10 },
      { assetId: 'TERRAIN_GRASS_STONES_001', weight: 9 },
      { assetId: 'TERRAIN_GRASS_WORN_001', weight: 11 }
    ]
  },
  soil: {
    id: 'soil', name: 'Solo fértil', color: '#816b48', walkable: true, movementCost: 1.1, variants: []
  },
  dry: {
    id: 'dry', name: 'Solo seco', color: '#927b58', walkable: true, movementCost: 1.15, variants: []
  },
  rock: {
    id: 'rock', name: 'Rocha', color: '#71746e', walkable: true, movementCost: 1.35, variants: []
  }
});

export const PLANNED_TERRAIN_IDS = Object.freeze([
  'TERRAIN_GRASS', 'TERRAIN_GRASS_DRY', 'TERRAIN_DIRT', 'TERRAIN_DIRT_DARK',
  'TERRAIN_MUD', 'TERRAIN_GRAVEL', 'TERRAIN_ROCK', 'TERRAIN_SAND',
  'TERRAIN_ASPHALT', 'TERRAIN_ROAD_DIRT', 'TERRAIN_SIDEWALK',
  'TERRAIN_WATER_SHALLOW', 'TERRAIN_WATER_DEEP'
]);

export function terrainForNoise(value) {
  if (value < -0.38) return 'water';
  if (value < -0.18) return 'wetland';
  if (value < 0.25) return 'grass';
  if (value < 0.48) return 'soil';
  if (value < 0.67) return 'dry';
  return 'rock';
}