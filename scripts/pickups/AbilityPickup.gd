extends Area2D
class_name AbilityPickup

export var ability: String
export var message: String
export var message_duration: int = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group('network_sync')

func _network_process(input: Dictionary):
	self.visible = !GlobalGameState.is_unlocked(ability)
	if self.visible && !get_overlapping_bodies().empty():
		GlobalGameState.unlocks[ability] = true
		UiMessageBus.show_message(message, message_duration)
