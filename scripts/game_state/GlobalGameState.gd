extends Node

var spawnPoint = 'default'

var unlocks: Dictionary = {'dragon': false, 'bubble': false, 'airdash': false, 'waterdash': false, 'infinidash': false, 'dragignore': false}

func _ready():
	pass # Replace with function body.

func is_unlocked(var ability: String) -> bool:
	return unlocks[ability]
