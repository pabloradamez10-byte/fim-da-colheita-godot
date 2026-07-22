export class InteractionSystem {
  findTarget(objects, player) {
    return objects.find(object => object.alive &&
      Math.abs(object.x - player.x) + Math.abs(object.y - player.y) <= 1 &&
      (object.type === 'tree' || object.type === 'stone')) || null;
  }

  interact(objects, player, inventory) {
    const target = this.findTarget(objects, player);
    if (!target) return { success: false, message: 'Chegue perto de uma árvore ou pedra.' };

    target.alive = false;
    const hadCampfire = inventory.campfire > 0;
    inventory.collect(target.type);
    if (!hadCampfire && inventory.campfire > 0) return { success: true, message: '🔥 Fogueira criada!' };
    return { success: true, message: target.type === 'tree' ? '+1 madeira' : '+1 pedra' };
  }
}
