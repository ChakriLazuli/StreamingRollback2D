extends Node

var spawnPoint = 'default'
var last_safe_location: Vector2 = Vector2.ZERO

var unlocks: Dictionary = {
	'dragon': false,
	'landbound': false, 
	'airdash': false, 
	'waterdash': true, 
	'infinidash': false, 
	'dragignore': false, 
	'wallcling': false
}

func _ready():
	add_to_group('network_sync')

func is_unlocked(var ability: String) -> bool:
	return unlocks[ability]

func _save_state() -> Dictionary:
	return {
		dragon = unlocks['dragon'],
		landbound = unlocks['landbound'],
		airdash = unlocks['airdash'],
		waterdash = unlocks['waterdash'],
		infinidash = unlocks['infinidash'],
		dragignore = unlocks['dragignore'],
		wallcling = unlocks['wallcling'],
	}

func _load_state(state: Dictionary):
	unlocks['dragon'] = state['dragon']
	unlocks['landbound'] = state['landbound']
	unlocks['airdash'] = state['airdash']
	unlocks['waterdash'] = state['waterdash']
	unlocks['infinidash'] = state['infinidash']
	unlocks['dragignore'] = state['dragignore']
	unlocks['wallcling'] = state['wallcling']
