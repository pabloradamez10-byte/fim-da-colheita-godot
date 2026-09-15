class_name NatureVisual062
extends RefCounted

const VERSION := "0.6.2-alpha"
const TREE_TEXTURE: Texture2D = preload("res://assets/nature/fdc_tree_pinus_adult_062.png")
const BUSH_TEXTURE: Texture2D = preload("res://assets/nature/fdc_bush_dense_062.png")
const ROCK_TEXTURE: Texture2D = preload("res://assets/nature/fdc_rock_mossy_062.png")

const VISUALS := {
	"tree": {"texture": TREE_TEXTURE, "pixel_size": 0.012, "height": 3.072},
	"bush": {"texture": BUSH_TEXTURE, "pixel_size": 0.004, "height": 1.024},
	"rock": {"texture": ROCK_TEXTURE, "pixel_size": 0.0036, "height": 0.922}
}

static func apply(root: Node3D, kind: String) -> Sprite3D:
	if root == null or not VISUALS.has(kind):
		return null
	_hide_procedural_meshes(root)
	var config: Dictionary = VISUALS[kind]
	var sprite := Sprite3D.new()
	sprite.name = "NatureSprite062_%s" % kind.capitalize()
	sprite.texture = config["texture"] as Texture2D
	sprite.pixel_size = float(config["pixel_size"])
	sprite.position = Vector3(0.0, float(config["height"]), 0.0)
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.shaded = false
	sprite.transparent = true
	sprite.double_sided = true
	sprite.add_to_group("nature_visual_062")
	sprite.add_to_group("nature_%s_062" % kind)
	root.add_child(sprite)
	root.set_meta("nature_visual_version", VERSION)
	root.set_meta("nature_kind", kind)
	return sprite

static func _hide_procedural_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = false
		_hide_procedural_meshes(child)
