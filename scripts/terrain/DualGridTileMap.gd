#Reference code taken from https://github.com/jess-hammer/dual-grid-tilemap-system-godot
extends TileMap
class_name DualGridTileMap

enum TileType {NONE = 0, GROUND = 1, WATER = 2}
const MOMENTUM_BY_TILE_TYPE: Dictionary = {
	TileType.NONE: Vector2(0,0), 
	TileType.GROUND: Vector2(0,0), 
	TileType.WATER: Vector2(0,-10)
}

const NEIGHBOURS = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]

export var none_placeholder_atlas_coord: Vector2
export var ground_placeholder_atlas_coord: Vector2
export var water_placeholder_atlas_coord: Vector2
export(NodePath) var ground_tile_map_path
onready var _ground_tile_map: TileMap = get_node(ground_tile_map_path)
export(NodePath) var water_tile_map_path
onready var _water_tile_map: TileMap = get_node(water_tile_map_path)

#export var test: PoolIntArray
#generalize for arbitrary number of tilesets later

func _ready():
	visible = false
	_ground_tile_map.visible = true
	_water_tile_map.visible = true
	for coords in get_used_cells():
		_set_display_tile(coords)

func _set_display_tile(coords: Vector2):
	for i in 4:
		var newPos: Vector2 = coords + NEIGHBOURS[i]
		_ground_tile_map.set_cellv(newPos, 0, false, false, false, _calculate_display_tile(newPos, TileType.GROUND))
		_water_tile_map.set_cellv(newPos, 0, false, false, false, _calculate_display_tile(newPos, TileType.WATER))

func _calculate_display_tile(coords: Vector2, tile_type: int) -> Vector2:
	var botRightType: int = _get_world_tile(coords - NEIGHBOURS[0])
	var botLeftType: int = _get_world_tile(coords - NEIGHBOURS[1])
	var topRightType: int = _get_world_tile(coords - NEIGHBOURS[2])
	var topLeftType: int = _get_world_tile(coords - NEIGHBOURS[3])
	var botRight = botRightType == tile_type
	var botLeft = botLeftType == tile_type
	var topRight = topRightType == tile_type
	var topLeft = topLeftType == tile_type
	var result = NEIGHBOURS_TO_ATLAS_COORDS[botRight][botLeft][topRight][topLeft]
	return result

func _get_world_tile(coords: Vector2) -> int:
	var atlas_coords: Vector2 = get_cell_autotile_coord(coords.x, coords.y)
	match atlas_coords:
		ground_placeholder_atlas_coord:
			return TileType.GROUND
		water_placeholder_atlas_coord:
			return TileType.WATER
	return TileType.NONE

func set_tile(coords: Vector2, atlas_coords: Vector2):
	set_cellv(coords, 0, false, false, false, atlas_coords)
	_set_display_tile(coords)

func get_tile_type_at(global_pos: Vector2) -> int:
	var relative_pos = global_pos - global_position
	var tile_coords_f = relative_pos/cell_size
	var tile_coords = Vector2(floor(tile_coords_f.x),floor(tile_coords_f.y))
	var tile = get_cell_autotile_coord(tile_coords.x, tile_coords.y)
	match tile:
		ground_placeholder_atlas_coord:
			return TileType.GROUND
		water_placeholder_atlas_coord:
			return TileType.WATER
	return TileType.NONE

func get_momentum_for_tile_type(tile_type: int) -> Vector2:
	return MOMENTUM_BY_TILE_TYPE[tile_type]

func get_drag_for_tile_type(tile_type: int) -> int:
	if TileType.GROUND == tile_type || TileType.NONE == tile_type:
		return 0
	return 1

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
