export const ASSET_DEFINITIONS = Object.freeze([
  { id: 'CHARACTER_PLAYER_S', type: 'image', path: './assets/characters/CHR_M_SURVIVOR_0001_S.png' },
  { id: 'CHARACTER_PLAYER_E', type: 'image', path: './assets/characters/CHR_M_SURVIVOR_0001_E.png' },
  { id: 'CHARACTER_PLAYER_N', type: 'image', path: './assets/characters/CHR_M_SURVIVOR_0001_N.png' },
  { id: 'CHARACTER_PLAYER_W', type: 'image', path: './assets/characters/CHR_M_SURVIVOR_0001_W.png' },
  { id: 'TERRAIN_GRASS_001', type: 'image', path: './assets/terrain/TERRAIN_GRASS_001.png' },
  { id: 'TERRAIN_GRASS_002', type: 'image', path: './assets/terrain/TERRAIN_GRASS_002.png' },
  { id: 'TERRAIN_GRASS_003', type: 'image', path: './assets/terrain/TERRAIN_GRASS_003.png' },
  { id: 'TERRAIN_GRASS_FLOWERS_001', type: 'image', path: './assets/terrain/TERRAIN_GRASS_FLOWERS_001.png' },
  { id: 'TERRAIN_GRASS_STONES_001', type: 'image', path: './assets/terrain/TERRAIN_GRASS_STONES_001.png' },
  { id: 'TERRAIN_GRASS_WORN_001', type: 'image', path: './assets/terrain/TERRAIN_GRASS_WORN_001.png' },
  { id: 'TERRAIN_DIRT_001', type: 'image', path: './assets/terrain/TERRAIN_DIRT_001.png' },
  { id: 'TERRAIN_DIRT_DARK_001', type: 'image', path: './assets/terrain/TERRAIN_DIRT_DARK_001.png' },
  { id: 'TERRAIN_MUD_001', type: 'image', path: './assets/terrain/TERRAIN_MUD_001.png' },
  { id: 'TERRAIN_GRAVEL_001', type: 'image', path: './assets/terrain/TERRAIN_GRAVEL_001.png' },
  { id: 'TERRAIN_ROCK_001', type: 'image', path: './assets/terrain/TERRAIN_ROCK_001.png' },
  { id: 'TERRAIN_SAND_001', type: 'image', path: './assets/terrain/TERRAIN_SAND_001.png' },
  { id: 'TERRAIN_ASPHALT_001', type: 'image', path: './assets/terrain/TERRAIN_ASPHALT_001.png' },
  { id: 'TERRAIN_ROAD_DIRT_001', type: 'image', path: './assets/terrain/TERRAIN_ROAD_DIRT_001.png' },
  { id: 'TERRAIN_SIDEWALK_001', type: 'image', path: './assets/terrain/TERRAIN_SIDEWALK_001.png' },
  { id: 'TERRAIN_WATER_SHALLOW_001', type: 'image', path: './assets/terrain/TERRAIN_WATER_SHALLOW_001.png' },
  { id: 'TERRAIN_WATER_DEEP_001', type: 'image', path: './assets/terrain/TERRAIN_WATER_DEEP_001.png' },
  { id: 'TREE_GENERIC_ALPHA', type: 'image', path: './assets/vegetation/TREE_GENERIC_ALPHA.png' },
  { id: 'BUSH_GENERIC_ALPHA', type: 'image', path: './assets/vegetation/BUSH_GENERIC_ALPHA.png' },
  { id: 'STONE_GENERIC_ALPHA', type: 'image', path: './assets/props/STONE_GENERIC_ALPHA.png' }
]);

export const PLAYER_ASSETS_BY_DIRECTION = Object.freeze({
  down: 'CHARACTER_PLAYER_S',
  right: 'CHARACTER_PLAYER_E',
  up: 'CHARACTER_PLAYER_N',
  left: 'CHARACTER_PLAYER_W'
});

export const OBJECT_ASSETS_BY_TYPE = Object.freeze({
  tree: Object.freeze({ assetId: 'TREE_GENERIC_ALPHA', height: 112 }),
  bush: Object.freeze({ assetId: 'BUSH_GENERIC_ALPHA', height: 52 }),
  stone: Object.freeze({ assetId: 'STONE_GENERIC_ALPHA', height: 44 })
});
