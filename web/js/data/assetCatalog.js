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
  { id: 'TERRAIN_GRASS_WORN_001', type: 'image', path: './assets/terrain/TERRAIN_GRASS_WORN_001.png' }
]);

export const PLAYER_ASSETS_BY_DIRECTION = Object.freeze({
  down: 'CHARACTER_PLAYER_S',
  right: 'CHARACTER_PLAYER_E',
  up: 'CHARACTER_PLAYER_N',
  left: 'CHARACTER_PLAYER_W'
});