extends Node

enum Type {NONE, GROUND, WATER, 
	WATER_DOWN1, WATER_UP1, WATER_RIGHT1, WATER_LEFT1,
	WATER_DOWN2, WATER_UP2, WATER_RIGHT2, WATER_LEFT2,
	}

const MOMENTUM_BY_TILE_TYPE: Dictionary = {
	Type.NONE: Vector2(0,0), 
	Type.GROUND: Vector2(0,0), 
	Type.WATER: Vector2(0,-10)
}

func get_momentum_for_tile_type(tile_type: int) -> Vector2:
	return MOMENTUM_BY_TILE_TYPE[tile_type]

func get_drag_for_tile_type(tile_type: int) -> int:
	if is_tile_water(tile_type):
		return 1
	return 0

func is_tile_water(tile_type: int) -> bool:
	match tile_type:
		Type.WATER:
			return true
	return false
