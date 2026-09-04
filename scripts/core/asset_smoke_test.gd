extends SceneTree

func _initialize() -> void:
	var asset_ids := ["grass", "dirt", "mud", "soil", "water", "tree", "rock", "bush", "fence", "house", "barn", "crate", "player", "zombie", "machete", "axe", "pistol", "shotgun"]
	for asset_id in asset_ids:
		var texture := VisualAssets.texture(asset_id)
		if texture == null:
			push_error("ASSET SMOKE: falha ao criar %s" % asset_id)
			quit(1)
			return
		var size := texture.get_size()
		if size.x <= 0 or size.y <= 0:
			push_error("ASSET SMOKE: tamanho inválido em %s" % asset_id)
			quit(1)
			return
	print("ASSET SMOKE OK — %d assets decodificados" % asset_ids.size())
	quit(0)
