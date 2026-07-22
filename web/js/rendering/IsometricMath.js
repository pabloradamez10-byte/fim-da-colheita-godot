export function worldToScreen(x, y, tileWidth, tileHeight) {
  return {
    x: (x - y) * tileWidth / 2,
    y: (x + y) * tileHeight / 2
  };
}

export function screenToWorld(screenX, screenY, tileWidth, tileHeight) {
  return {
    x: screenX / tileWidth + screenY / tileHeight,
    y: screenY / tileHeight - screenX / tileWidth
  };
}

export function drawIsometricTile(context, centerX, centerY, tileWidth, tileHeight) {
  context.beginPath();
  context.moveTo(centerX, centerY - tileHeight / 2);
  context.lineTo(centerX + tileWidth / 2, centerY);
  context.lineTo(centerX, centerY + tileHeight / 2);
  context.lineTo(centerX - tileWidth / 2, centerY);
  context.closePath();
}

export function drawSpriteWithPivot(context, image, groundX, groundY, options = {}) {
  const height = options.height || image.naturalHeight;
  const width = options.width || height * image.naturalWidth / image.naturalHeight;
  const pivotX = options.pivotX ?? 0.5;
  const pivotY = options.pivotY ?? 1;
  const groundOffset = options.groundOffset ?? 0;
  const drawX = Math.round(groundX - width * pivotX);
  const drawY = Math.round(groundY - height * pivotY + groundOffset);
  context.drawImage(image, drawX, drawY, Math.round(width), Math.round(height));
  return { x: drawX, y: drawY, width: Math.round(width), height: Math.round(height) };
}

export function isTileVisible(screenX, screenY, viewportWidth, viewportHeight, tileWidth, tileHeight, margin = 1) {
  const horizontalMargin = tileWidth * margin;
  const verticalMargin = tileHeight * margin;
  return screenX + tileWidth / 2 >= -horizontalMargin &&
    screenX - tileWidth / 2 <= viewportWidth + horizontalMargin &&
    screenY + tileHeight / 2 >= -verticalMargin &&
    screenY - tileHeight / 2 <= viewportHeight + verticalMargin;
}

export function sortByDepth(drawables) {
  return drawables.sort((left, right) =>
    left.depth - right.depth || (left.layer || 0) - (right.layer || 0));
}
