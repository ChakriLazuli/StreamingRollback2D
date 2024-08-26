#Reference code taken from https://github.com/jess-hammer/dual-grid-tilemap-system-godot
extends TileMap

enum TileType {NONE = 0, GROUND = 1, WATER = 2}
const NEIGHBOURS = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]

export var none_placeholder_atlas_coord: Vector2
export var ground_placeholder_atlas_coord: Vector2
var _display_tile_map: TileMap

func _ready():
	pass

func set_tile_map(tile_map: TileMap):
	_display_tile_map = tile_map
	visible = false
	for coord in get_used_cells():
		_set_display_tile(coord)

func set_tile(coords: Vector2, atlas_coords: Vector2):
	set_cellv(coords, 0, false, false, false, atlas_coords)
	_set_display_tile(coords)

func _set_display_tile(coords: Vector2):
	for i in 4:
		var newPos: Vector2 = coords + NEIGHBOURS[i]
		_display_tile_map.set_cellv(newPos, 0, false, false, false, _calculate_display_tile(newPos))

func _calculate_display_tile(coords: Vector2) -> Vector2:
	var botRight: int = _get_world_tile(coords - NEIGHBOURS[0])
	var botLeft: int = _get_world_tile(coords - NEIGHBOURS[1])
	var topRight: int = _get_world_tile(coords - NEIGHBOURS[2])
	var topLeft: int = _get_world_tile(coords - NEIGHBOURS[3])
	var result = NEIGHBOURS_TO_ATLAS_COORDS[botRight][botLeft][topRight][topLeft]
	return result

func _get_world_tile(coords: Vector2) -> int:
	var atlas_coord: Vector2 = get_cell_autotile_coord(coords.x, coords.y)
	if atlas_coord == ground_placeholder_atlas_coord:
		return TileType.GROUND
	else:
		return TileType.NONE

const NEIGHBOURS_TO_ATLAS_COORDS: Dictionary = {TileType.NONE: {
		TileType.NONE: {
			TileType.NONE: {
				TileType.NONE: Vector2(0,3),
				TileType.GROUND: Vector2(3,3)
			}, TileType.GROUND: {
				TileType.NONE: Vector2(0,2),
				TileType.GROUND: Vector2(1,2)
			}
		},
		TileType.GROUND:  {
			TileType.NONE: {
				TileType.NONE: Vector2(0,0),
				TileType.GROUND: Vector2(2,3)
			}, TileType.GROUND: {
				TileType.NONE: Vector2(3,2),
				TileType.GROUND: Vector2(3,1)
			}
		}
	}, TileType.GROUND: {
		TileType.NONE: {
			TileType.NONE: {
				TileType.NONE: Vector2(1,3),
				TileType.GROUND: Vector2(0,1)
			}, TileType.GROUND: {
				TileType.NONE: Vector2(1,0),
				TileType.GROUND: Vector2(2,2)
			}
		},
		TileType.GROUND:  {
			TileType.NONE: {
				TileType.NONE: Vector2(3,0),
				TileType.GROUND: Vector2(2,0)
			}, TileType.GROUND: {
				TileType.NONE: Vector2(1,1),
				TileType.GROUND: Vector2(2,1)
			}
		}
	}
}

#using Godot;
#using System;
#using System.Collections.Generic;
#using static TileType;
#
#public partial class DualGridTilemap : TileMap {
#	[Export] TileMap displayTilemap;
#	[Export] public Vector2I grassPlaceholderAtlasCoord;
#	[Export] public Vector2I dirtPlaceholderAtlasCoord;
#	readonly Vector2I[] NEIGHBOURS = new Vector2I[] { new(0, 0), new(1, 0), new(0, 1), new(1, 1) };
#
#	readonly Dictionary<Tuple<TileType, TileType, TileType, TileType>, Vector2I> neighboursToAtlasCoord = new() {
#		{new (Grass, Grass, Grass, Grass), new Vector2I(2, 1)}, // All corners
#		{new (Dirt, Dirt, Dirt, Grass), new Vector2I(1, 3)}, // Outer bottom-right corner
#		{new (Dirt, Dirt, Grass, Dirt), new Vector2I(0, 0)}, // Outer bottom-left corner
#		{new (Dirt, Grass, Dirt, Dirt), new Vector2I(0, 2)}, // Outer top-right corner
#		{new (Grass, Dirt, Dirt, Dirt), new Vector2I(3, 3)}, // Outer top-left corner
#		{new (Dirt, Grass, Dirt, Grass), new Vector2I(1, 0)}, // Right edge
#		{new (Grass, Dirt, Grass, Dirt), new Vector2I(3, 2)}, // Left edge
#		{new (Dirt, Dirt, Grass, Grass), new Vector2I(3, 0)}, // Bottom edge
#		{new (Grass, Grass, Dirt, Dirt), new Vector2I(1, 2)}, // Top edge
#		{new (Dirt, Grass, Grass, Grass), new Vector2I(1, 1)}, // Inner bottom-right corner
#		{new (Grass, Dirt, Grass, Grass), new Vector2I(2, 0)}, // Inner bottom-left corner
#		{new (Grass, Grass, Dirt, Grass), new Vector2I(2, 2)}, // Inner top-right corner
#		{new (Grass, Grass, Grass, Dirt), new Vector2I(3, 1)}, // Inner top-left corner
#		{new (Dirt, Grass, Grass, Dirt), new Vector2I(2, 3)}, // Bottom-left top-right corners
#		{new (Grass, Dirt, Dirt, Grass), new Vector2I(0, 1)}, // Top-left down-right corners
#		{new (Dirt, Dirt, Dirt, Dirt), new Vector2I(0, 3)}, // No corners
#	};
#
#	public override void _Ready() {
#		// Refresh all display tiles
#		foreach (Vector2I coord in GetUsedCells(0)) {
#			setDisplayTile(coord);
#		}
#	}
#
#	public void SetTile(Vector2I coords, Vector2I atlasCoords) {
#		SetCell(0, coords, 0, atlasCoords);
#		setDisplayTile(coords);
#	}
#
#	void setDisplayTile(Vector2I pos) {
#		// loop through 4 display neighbours
#		for (int i = 0; i < NEIGHBOURS.Length; i++) {
#			Vector2I newPos = pos + NEIGHBOURS[i];
#			displayTilemap.SetCell(0, newPos, 1, calculateDisplayTile(newPos));
#		}
#	}
#
#	Vector2I calculateDisplayTile(Vector2I coords) {
#		// get 4 world tile neighbours
#		TileType botRight = getWorldTile(coords - NEIGHBOURS[0]);
#		TileType botLeft = getWorldTile(coords - NEIGHBOURS[1]);
#		TileType topRight = getWorldTile(coords - NEIGHBOURS[2]);
#		TileType topLeft = getWorldTile(coords - NEIGHBOURS[3]);
#
#		// return tile (atlas coord) that fits the neighbour rules
#		return neighboursToAtlasCoord[new(topLeft, topRight, botLeft, botRight)];
#	}
#
#	TileType getWorldTile(Vector2I coords) {
#		Vector2I atlasCoord = GetCellAtlasCoords(0, coords);
#		if (atlasCoord == grassPlaceholderAtlasCoord)
#			return Grass;
#		else
#			return Dirt;
#	}
#}
