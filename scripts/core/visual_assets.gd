class_name VisualAssets
extends RefCounted

static var _cache: Dictionary = {}

static func _find_spec(asset_id: String) -> Dictionary:
	for source in [
		VisualTerrainData.ASSETS,
		VisualNatureData.ASSETS,
		VisualStructuresData.ASSETS,
		VisualCharacterData.ASSETS,
		VisualItemData.ASSETS
	]:
		if source.has(asset_id):
			return source[asset_id]
	return {}

static func texture(asset_id: String) -> Texture2D:
	if _cache.has(asset_id):
		return _cache[asset_id]
	var spec := _find_spec(asset_id)
	if spec.is_empty():
		push_warning("VisualAssets: asset desconhecido: %s" % asset_id)
		return null

	var w := int(spec["w"])
	var h := int(spec["h"])
	var palette: Array[Color] = []
	for hex_value in spec["palette"]:
		palette.append(Color(str(hex_value)))

	var encoded: PackedByteArray = Marshalls.base64_to_raw(str(spec["rle"]))
	var image := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var cursor := 0
	var i := 0
	while i + 1 < encoded.size() and cursor < w * h:
		var count := int(encoded[i])
		var palette_index := int(encoded[i + 1])
		var color: Color = palette[palette_index] if palette_index < palette.size() else Color.MAGENTA
		for n in range(count):
			if cursor >= w * h:
				break
			var x := cursor % w
			var y := int(cursor / w)
			image.set_pixel(x, y, color)
			cursor += 1
		i += 2

	var tex := ImageTexture.create_from_image(image)
	_cache[asset_id] = tex
	return tex
