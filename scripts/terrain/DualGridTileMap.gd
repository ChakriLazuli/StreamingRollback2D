#Reference code taken from https://github.com/jess-hammer/dual-grid-tilemap-system-godot
extends TileMap
class_name DualGridTileMap

const NEIGHBOURS = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]

export(NodePath) var ground_tile_map_path
onready var _ground_tile_map: TileMap = get_node(ground_tile_map_path)
export(NodePath) var water_tile_map_path
onready var _water_tile_map: TileMap = get_node(water_tile_map_path)
export(NodePath) var direction_tile_map_path
onready var _direction_tile_map: TileMap = get_node(direction_tile_map_path)

#export var test: PoolIntArray
#generalize for arbitrary number of tilesets later

func _ready():
	TerrainRepository.tile_map = self
	visible = false
	_ground_tile_map.visible = true
	_water_tile_map.visible = true
	for coords in get_used_cells():
		_set_display_tile(coords)
		_direction_tile_map.set_cellv(coords, 0, false, false, false, _calculate_direction_tile(coords))

func _set_display_tile(coords: Vector2):
	for i in 4:
		var newPos: Vector2 = coords + NEIGHBOURS[i]
		_ground_tile_map.set_cellv(newPos, 0, false, false, false, _calculate_display_tile(newPos, TileData.SimpleType.GROUND))
		_water_tile_map.set_cellv(newPos, 0, false, false, false, _calculate_display_tile(newPos, TileData.SimpleType.WATER))

func _calculate_display_tile(coords: Vector2, simple_tile_type: int) -> Vector2:
	var botRightType: int = get_tile_type_at_cell(coords - NEIGHBOURS[0])
	var botLeftType: int = get_tile_type_at_cell(coords - NEIGHBOURS[1])
	var topRightType: int = get_tile_type_at_cell(coords - NEIGHBOURS[2])
	var topLeftType: int = get_tile_type_at_cell(coords - NEIGHBOURS[3])
	var botRight = TileData.get_simple_tile_type(botRightType) == simple_tile_type
	var botLeft = TileData.get_simple_tile_type(botLeftType) == simple_tile_type
	var topRight = TileData.get_simple_tile_type(topRightType) == simple_tile_type
	var topLeft = TileData.get_simple_tile_type(topLeftType) == simple_tile_type
	var result = TileData.NEIGHBOURS_TO_ATLAS_COORDS[botRight][botLeft][topRight][topLeft]
	return result

func _calculate_direction_tile(coords: Vector2) -> Vector2:
	var type = get_tile_type_at_cell(coords)
	return TileData.get_direction_atlas_coords(type)

func get_tile_type_at_cell(coords: Vector2) -> int:
	var atlas_coords: Vector2 = get_cell_autotile_coord(coords.x, coords.y)
	return TileData.get_tile_type_from_atlas(atlas_coords)

func set_tile(coords: Vector2, atlas_coords: Vector2):
	set_cellv(coords, 0, false, false, false, atlas_coords)
	_set_display_tile(coords)

func get_tile_type_at_position(global_pos: Vector2) -> int:
	var relative_pos = global_pos - global_position
	var tile_coords_f = relative_pos/cell_size
	var tile_coords = Vector2(floor(tile_coords_f.x),floor(tile_coords_f.y))
	return get_tile_type_at_cell(tile_coords)
