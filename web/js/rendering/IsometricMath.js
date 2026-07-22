export function worldToScreen(x, y, tileWidth, tileHeight) {
  return {
    x: (x - y) * tileWidth / 2,
    y: (x + y) * tileHeight / 2
  };
}

export function createDiamondPath(context, centerX, centerY, tileWidth, tileHeight) {
  context.beginPath();
  context.moveTo(centerX, centerY - tileHeight / 2);
  context.lineTo(centerX + tileWidth / 2, centerY);
  context.lineTo(centerX, centerY + tileHeight / 2);
  context.lineTo(centerX - tileWidth / 2, centerY);
  context.closePath();
}
