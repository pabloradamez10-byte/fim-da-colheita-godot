export class InventorySystem {
  constructor(data = {}) {
    this.wood = Number(data.wood) || 0;
    this.stone = Number(data.stone) || 0;
    this.campfire = Number(data.campfire) || 0;
  }

  collect(type) {
    if (type === 'tree') this.wood++;
    if (type === 'stone') this.stone++;
    this.craftAutomaticCampfire();
  }

  craftAutomaticCampfire() {
    if (this.campfire || this.wood < 3 || this.stone < 2) return false;
    this.wood -= 3;
    this.stone -= 2;
    this.campfire = 1;
    return true;
  }

  serialize() {
    return { wood: this.wood, stone: this.stone, campfire: this.campfire };
  }
}
