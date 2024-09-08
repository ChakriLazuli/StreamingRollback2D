extends Node

enum Type {NONE, AIRN, AIRNE, AIRE, AIRSE, AIRS, AIRSW, AIRW, AIRNW, 
	AIR, AIRN2, AIRNE2, AIRE2, AIRSE2, AIRS2, AIRSW2, AIRW2, AIRNW2,
	WATER, WATERN, WATERNE, WATERE, WATERSE, WATERS, WATERSW, WATERW, WATERNW, 
	WATER2, WATERN2, WATERNE2, WATERE2, WATERSE2, WATERS2, WATERSW2, WATERW2, WATERNW2,
	GROUND, GROUNDSLIP, GROUNDOTHER, WOOD, WOODSLIP, WOODOTHER, OTHER, OTHERSLIP, OTHEROTHER}

enum SimpleType {AIR, WATER, GROUND}

enum DirectionType {NONE, N, NE, E, SE, S, SW, W, NW}
const DIRECTIONS: Dictionary = {0: Vector2(0,0), 1: Vector2(0,-3), 2: Vector2(2,-2), 
	3: Vector2(3,0), 4: Vector2(2,2), 5: Vector2(0,3),
	6: Vector2(-2,2), 7: Vector2(-3,0), 8: Vector2(-2,-2)}
	
enum SpeedType {NONE, SLOW, FAST}
const SPEEDS: Dictionary = {SpeedType.NONE: 0, SpeedType.SLOW: 1, SpeedType.FAST: 3}

func get_tile_type_from_atlas(atlas_coords: Vector2) -> int:
	return 9 * int(atlas_coords.y) + int(atlas_coords.x)

func get_tile_type_from_parts(simple_type: int, direction_type: int, speed_type: int) -> int:
	var simple_row = simple_type * 2
	var speed_row
	if (speed_type == SpeedType.FAST):
		speed_row = 1
	else:
		speed_row = 0
	return 9 * (simple_row + speed_row) + direction_type

func get_simple_tile_type(tile_type: int) -> int:
	if tile_type < 18:
		return SimpleType.AIR
	if tile_type < 36:
		return SimpleType.WATER
	return SimpleType.GROUND

func get_direction_tile_type(tile_type: int) -> int:
	if tile_type >= 36:
		return DirectionType.NONE
	return tile_type % 9

func get_speed_tile_type(tile_type: int) -> int:
	if tile_type >= 36:
		return SpeedType.NONE
	if tile_type % 9 == 0:
		return SpeedType.NONE
	if tile_type % 18 < 9:
		return SpeedType.SLOW
	return SpeedType.FAST

func get_momentum_for_tile_type(tile_type: int) -> Vector2:
	return DIRECTIONS[get_direction_tile_type(tile_type)] * SPEEDS[get_speed_tile_type(tile_type)]

func get_drag_for_tile_type(tile_type: int) -> int:
	if is_tile_water(tile_type):
		return 2
	return 0

func is_tile_water(tile_type: int) -> bool:
	match get_simple_tile_type(tile_type):
		SimpleType.WATER:
			return true
	return false

func get_surface_drag(tile_type: int, immersion_tile_type: int) -> int:
	if is_tile_water(immersion_tile_type):
		if !is_tile_slip(tile_type):
			return 3
	return 0

func is_tile_slip(tile_type: int) -> bool:
	match tile_type:
		Type.GROUNDSLIP:
			return true
		Type.WOODSLIP:
			return true
		Type.OTHERSLIP:
			return true
	return false

func get_direction_atlas_coordsv(atlas_coords: Vector2) -> Vector2:
	return Vector2(atlas_coords.x, int(atlas_coords.y) % 2)

func get_direction_atlas_coords(tile_type: int) -> Vector2:
	var direction_type = get_direction_tile_type(tile_type)
	var speed_type = get_speed_tile_type(tile_type)
	var x = direction_type
	var y = 0
	if speed_type == SpeedType.FAST:
		y = 1
	return Vector2(x, y)

const NEIGHBOURS_TO_ATLAS_COORDS: Dictionary = {false: {
		false: {
			false: {
				false: Vector2(0,3),
				true: Vector2(3,3)
			}, true: {
				false: Vector2(0,2),
				true: Vector2(1,2)
			}
		},
		true:  {
			false: {
				false: Vector2(0,0),
				true: Vector2(3,2)
			}, true: {
				false: Vector2(2,3),
				true: Vector2(3,1)
			}
		}
	}, true: {
		false: {
			false: {
				false: Vector2(1,3),
				true: Vector2(0,1)
			}, true: {
				false: Vector2(1,0),
				true: Vector2(2,2)
			}
		},
		true:  {
			false: {
				false: Vector2(3,0),
				true: Vector2(2,0)
			}, true: {
				false: Vector2(1,1),
				true: Vector2(2,1)
			}
		}
	}
}
