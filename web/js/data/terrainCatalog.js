export const TERRAIN_CATALOG = Object.freeze({
  water: {
    id: 'water', name: 'Água profunda', color: '#245d72', walkable: false, movementCost: Infinity,
    variants: [{ assetId: 'TERRAIN_WATER_DEEP_001', weight: 1 }]
  },
  wetland: {
    id: 'wetland', name: 'Água rasa', color: '#4f7055', walkable: true, movementCost: 1.5,
    variants: [{ assetId: 'TERRAIN_WATER_SHALLOW_001', weight: 1 }]
  },
  grass: {
    id: 'grass',
    name: 'Grama',
    color: '#668b4f',
    walkable: true,
    movementCost: 1,
    variants: [
      { assetId: 'TERRAIN_GRASS_001', weight: 58 },
      { assetId: 'TERRAIN_GRASS_002', weight: 16 },
      { assetId: 'TERRAIN_GRASS_003', weight: 10 },
      { assetId: 'TERRAIN_GRASS_FLOWERS_001', weight: 5 },
      { assetId: 'TERRAIN_GRASS_STONES_001', weight: 5 },
      { assetId: 'TERRAIN_GRASS_WORN_001', weight: 6 }
    ]
  },
  soil: {
    id: 'soil', name: 'Solo fértil', color: '#816b48', walkable: true, movementCost: 1.1,
    variants: [
      { assetId: 'TERRAIN_DIRT_001', weight: 68 },
      { assetId: 'TERRAIN_DIRT_DARK_001', weight: 22 },
      { assetId: 'TERRAIN_MUD_001', weight: 10 }
    ]
  },
  dry: {
    id: 'dry', name: 'Solo seco', color: '#927b58', walkable: true, movementCost: 1.15,
    variants: [
      { assetId: 'TERRAIN_DIRT_001', weight: 70 },
      { assetId: 'TERRAIN_GRAVEL_001', weight: 20 },
      { assetId: 'TERRAIN_SAND_001', weight: 10 }
    ]
  },
  rock: {
    id: 'rock', name: 'Rocha', color: '#71746e', walkable: true, movementCost: 1.35,
    variants: [
      { assetId: 'TERRAIN_ROCK_001', weight: 85 },
      { assetId: 'TERRAIN_GRAVEL_001', weight: 15 }
    ]
  }
});

export const PLANNED_TERRAIN_IDS = Object.freeze([
  'TERRAIN_GRASS_001', 'TERRAIN_GRASS_002', 'TERRAIN_GRASS_003',
  'TERRAIN_GRASS_FLOWERS_001', 'TERRAIN_GRASS_STONES_001', 'TERRAIN_GRASS_WORN_001',
  'TERRAIN_DIRT_001', 'TERRAIN_DIRT_DARK_001', 'TERRAIN_MUD_001',
  'TERRAIN_GRAVEL_001', 'TERRAIN_ROCK_001', 'TERRAIN_SAND_001',
  'TERRAIN_ASPHALT_001', 'TERRAIN_ROAD_DIRT_001', 'TERRAIN_SIDEWALK_001',
  'TERRAIN_WATER_SHALLOW_001', 'TERRAIN_WATER_DEEP_001'
]);

export function terrainForNoise(value) {
  if (value < -1.15) return 'water';
  if (value < -0.65) return 'wetland';
  if (value < 0.55) return 'grass';
  if (value < 1.05) return 'soil';
  if (value < 1.45) return 'dry';
  return 'rock';
}
