const ASSET_VERSION = '20260722-02';

export const ASSET_CATALOG = Object.freeze({
  CHARACTER_PLAYER_S: `./assets/characters/CHR_M_SURVIVOR_0001_S.png?v=${ASSET_VERSION}`,
  CHARACTER_PLAYER_E: `./assets/characters/CHR_M_SURVIVOR_0001_E.png?v=${ASSET_VERSION}`,
  CHARACTER_PLAYER_N: `./assets/characters/CHR_M_SURVIVOR_0001_N.png?v=${ASSET_VERSION}`,
  CHARACTER_PLAYER_W: `./assets/characters/CHR_M_SURVIVOR_0001_W.png?v=${ASSET_VERSION}`,
  TERRAIN_GRASS_001: `./assets/terrain/TERRAIN_GRASS_001.png?v=${ASSET_VERSION}`
});

export const PLAYER_ASSETS_BY_DIRECTION = Object.freeze({
  down: 'CHARACTER_PLAYER_S',
  right: 'CHARACTER_PLAYER_E',
  up: 'CHARACTER_PLAYER_N',
  left: 'CHARACTER_PLAYER_W'
});
