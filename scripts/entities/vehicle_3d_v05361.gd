extends "res://scripts/entities/vehicle_3d_v05362.gd"

# Compatibilidade 0.5.36.1: a implementação definitiva da frota foi consolidada
# na 0.5.36.2 para evitar os quatro PNGs intermediários corrompidos.
func get_vehicle_art_debug_05361() -> Dictionary:
	var data := get_vehicle_art_debug_05362()
	data["compat_05361"] = true
	return data
