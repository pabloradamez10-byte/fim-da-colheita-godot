export class Player {
  constructor(data = {}) {
    this.x = data.x ?? 0;
    this.y = data.y ?? 0;
    this.direction = data.direction || 'down';
  }

  face(dx, dy) {
    if (dx > 0) this.direction = 'right';
    else if (dx < 0) this.direction = 'left';
    else if (dy > 0) this.direction = 'down';
    else if (dy < 0) this.direction = 'up';
  }

  moveTo(x, y) {
    this.x = x;
    this.y = y;
  }

  serialize() {
    return { x: this.x, y: this.y, direction: this.direction };
  }
}
