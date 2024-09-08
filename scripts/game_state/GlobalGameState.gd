extends Node

var spawnPoint = 'default'
var last_safe_location: Vector2 = Vector2.ZERO

var unlocks: Dictionary = {
	'dragon': true,
	'bubble': true, 
	'airdash': true, 
	'waterdash': true, 
	'infinidash': true, 
	'dragignore': false, 
	'wallcling': true
}

func _ready():
	add_to_group('network_sync')

func is_unlocked(var ability: String) -> bool:
	return unlocks[ability]

func _save_state() -> Dictionary:
	return {
		dragon = unlocks['dragon'],
		bubble = unlocks['bubble'],
		airdash = unlocks['airdash'],
		waterdash = unlocks['waterdash'],
		infinidash = unlocks['infinidash'],
		dragignore = unlocks['dragignore'],
		wallcling = unlocks['wallcling'],
	}

func _load_state(state: Dictionary):
	unlocks['dragon'] = state['dragon']
	unlocks['bubble'] = state['bubble']
	unlocks['airdash'] = state['airdash']
	unlocks['waterdash'] = state['waterdash']
	unlocks['infinidash'] = state['infinidash']
	unlocks['dragignore'] = state['dragignore']
	unlocks['wallcling'] = state['wallcling']
