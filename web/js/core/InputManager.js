const KEY_DIRECTIONS = Object.freeze({
  ArrowUp: [0, -1], w: [0, -1], W: [0, -1],
  ArrowDown: [0, 1], s: [0, 1], S: [0, 1],
  ArrowLeft: [-1, 0], a: [-1, 0], A: [-1, 0],
  ArrowRight: [1, 0], d: [1, 0], D: [1, 0]
});

const MOBILE_DIRECTIONS = Object.freeze({
  up: [0, -1], down: [0, 1], left: [-1, 0], right: [1, 0]
});

export class InputManager {
  constructor({ onMove, onInteract, onNewWorld }) {
    this.onMove = onMove;
    this.onInteract = onInteract;
    this.onNewWorld = onNewWorld;
  }

  bind() {
    addEventListener('keydown', event => {
      const direction = KEY_DIRECTIONS[event.key];
      if (direction) {
        event.preventDefault();
        this.onMove(...direction);
      }
      if (event.key === 'e' || event.key === 'E' || event.key === ' ') {
        event.preventDefault();
        this.onInteract();
      }
    });

    document.querySelectorAll('[data-dir]').forEach(button => {
      button.addEventListener('pointerdown', event => {
        event.preventDefault();
        this.onMove(...MOBILE_DIRECTIONS[button.dataset.dir]);
      });
    });

    document.querySelector('#interact').addEventListener('click', this.onInteract);
    document.querySelector('#newWorld').addEventListener('click', this.onNewWorld);
  }
}
