export class Camera {
  constructor({ smoothing = 0.16 } = {}) {
    this.x = 0;
    this.y = 0;
    this.smoothing = smoothing;
    this.initialized = false;
  }

  follow(targetX, targetY, viewportWidth, viewportHeight) {
    const desiredX = viewportWidth / 2 - targetX;
    const desiredY = viewportHeight / 2 - targetY;

    if (!this.initialized) {
      this.x = desiredX;
      this.y = desiredY;
      this.initialized = true;
      return;
    }

    this.x += (desiredX - this.x) * this.smoothing;
    this.y += (desiredY - this.y) * this.smoothing;
  }

  apply(point) {
    return { x: point.x + this.x, y: point.y + this.y };
  }

  reset() {
    this.initialized = false;
  }
}
