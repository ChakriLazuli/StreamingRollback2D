extends Node

const UPDATE_PROXIMITY = Vector2(2000, 2000)

var player: Player

func should_update(entity: Node2D) -> bool:
	var distance = entity.global_position - player.global_position
	return abs(distance.x < UPDATE_PROXIMITY.x) && abs(distance.y < UPDATE_PROXIMITY.y)
