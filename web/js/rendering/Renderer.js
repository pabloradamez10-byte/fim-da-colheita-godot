import { PLAYER_ASSETS_BY_DIRECTION } from '../data/assetCatalog.js';
import { Camera } from './Camera.js';
import {
  drawIsometricTile,
  drawSpriteWithPivot,
  isTileVisible,
  sortByDepth,
  worldToScreen
} from './IsometricMath.js';

export class Renderer {
  constructor(canvas, config, assetManager, terrainManager) {
    this.canvas = canvas;
    this.context = canvas.getContext('2d');
    this.config = config;
    this.assetManager = assetManager;
    this.terrainManager = terrainManager;
    this.camera = new Camera();
    this.visibleTileCount = 0;
  }

  resize() {
    const rect = this.canvas.getBoundingClientRect();
    const dpr = Math.min(devicePixelRatio || 1, 2);
    this.canvas.width = Math.floor(rect.width * dpr);
    this.canvas.height = Math.floor(rect.height * dpr);
    this.context.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  render(state) {
    const width = this.canvas.clientWidth;
    const height = this.canvas.clientHeight;
    this.context.clearRect(0, 0, width, height);
    const playerScreen = this.toScreen(state.player.x, state.player.y);
    this.camera.follow(playerScreen.x, playerScreen.y, width, height);
    this.visibleTileCount = 0;

    for (let y = 0; y < this.config.height; y++) {
      for (let x = 0; x < this.config.width; x++) {
        const point = this.toCameraScreen(x, y);
        if (!isTileVisible(point.x, point.y, width, height,
          this.config.tileWidth, this.config.tileHeight, 2)) continue;
        this.drawTile(point.x, point.y, state.terrain[y][x], x, y, state.seed);
        this.visibleTileCount++;
      }
    }

    const drawables = state.objects.filter(object => object.alive)
      .filter(object => {
        const point = this.toCameraScreen(object.x, object.y);
        return isTileVisible(point.x, point.y, width, height,
          this.config.tileWidth, this.config.tileHeight, 4);
      })
      .map(object => ({ depth: object.x + object.y, layer: 0, kind: 'object', data: object }));
    drawables.push({ depth: state.player.x + state.player.y, layer: 1, kind: 'player' });
    sortByDepth(drawables);

    for (const drawable of drawables) {
      if (drawable.kind === 'player') this.drawPlayer(state.player);
      else this.drawObject(drawable.data);
    }
  }

  toScreen(x, y) {
    return worldToScreen(x, y, this.config.tileWidth, this.config.tileHeight);
  }

  toCameraScreen(x, y) {
    const point = this.toScreen(x, y);
    return this.camera.apply(point);
  }

  drawTile(x, y, terrainId, gridX, gridY, seed) {
    drawIsometricTile(this.context, x, y, this.config.tileWidth, this.config.tileHeight);
    this.context.fillStyle = this.terrainManager.getFallbackColor(terrainId);
    this.context.fill();

    const assetId = this.terrainManager.getVariantAssetId(terrainId, gridX, gridY, seed);
    const image = assetId ? this.assetManager.getImage(assetId) : null;
    if (image) {
      this.context.save();
      drawIsometricTile(this.context, x, y, this.config.tileWidth, this.config.tileHeight);
      this.context.clip();
      this.context.drawImage(image, x - this.config.tileWidth / 2, y - this.config.tileHeight / 2,
        this.config.tileWidth, this.config.tileHeight);
      this.context.restore();
    }

    drawIsometricTile(this.context, x, y, this.config.tileWidth, this.config.tileHeight);
    this.context.strokeStyle = 'rgba(15,25,17,.22)';
    this.context.stroke();
  }

  drawObject(object) {
    const point = this.toCameraScreen(object.x, object.y);
    if (object.type === 'tree') {
      this.context.fillStyle = '#5e422d';
      this.context.fillRect(point.x - 3, point.y - 24, 6, 24);
      this.context.fillStyle = '#2e5634';
      this.context.beginPath();
      this.context.arc(point.x, point.y - 31, 14, 0, Math.PI * 2);
      this.context.fill();
    } else if (object.type === 'stone') {
      this.context.fillStyle = '#5d625e';
      this.context.beginPath();
      this.context.ellipse(point.x, point.y - 7, 11, 8, -0.2, 0, Math.PI * 2);
      this.context.fill();
    } else {
      this.context.fillStyle = '#466f43';
      this.context.beginPath();
      this.context.arc(point.x, point.y - 7, 8, 0, Math.PI * 2);
      this.context.fill();
    }
  }

  drawPlayer(player) {
    const point = this.toCameraScreen(player.x, player.y);
    const image = this.assetManager.getImage(PLAYER_ASSETS_BY_DIRECTION[player.direction]);
    if (!image) return this.drawFallbackPlayer(point.x, point.y);
    drawSpriteWithPivot(this.context, image, point.x, point.y, {
      height: 104,
      pivotX: 0.5,
      pivotY: 1,
      groundOffset: 18
    });
  }

  drawFallbackPlayer(x, y) {
    this.context.fillStyle = '#e6c49b';
    this.context.beginPath();
    this.context.arc(x, y - 20, 8, 0, Math.PI * 2);
    this.context.fill();
    this.context.fillStyle = '#365f42';
    this.context.fillRect(x - 7, y - 12, 14, 19);
  }
}
