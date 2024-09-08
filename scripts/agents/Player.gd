extends Agent
class_name Player

var _input_vector: Vector2

func _ready():
	._ready()
	PlayerRepository.player = self

func _get_local_input() -> Dictionary:
	var input := {}
	
	_input_vector = Input.get_vector("0_left", "0_right", "0_up", "0_down")
	input["x"] = int(round(_input_vector.x))
	input["y"] = int(round(_input_vector.y))
	input["jump"] = Input.is_action_pressed("0_jump")
	input["dash"] = Input.is_action_pressed("0_dash")
	input["attack"] = Input.is_action_pressed("0_attack")
	return input
