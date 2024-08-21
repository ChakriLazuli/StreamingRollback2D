extends KinematicBody2D

onready var check_down = $CheckDown
onready var check_up = $CheckUp
onready var check_right = $CheckRight
onready var check_left = $CheckLeft

var attached_down = false
var attached_up = false
var attached_right = false
var attached_left = false

func _ready():
	pass 

func _get_local_input() -> Dictionary:
	var input := {}
	
	var input_vector = Input.get_vector("0_left", "0_right", "0_up", "0_down")
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	
	input["jump"] = Input.is_action_pressed("0_jump")
	input["dash"] = Input.is_action_pressed("0_dash")
	input["attack"] = Input.is_action_pressed("0_attack")
	return input

func _network_process(input: Dictionary):
	var input_vector = input.get("input_vector", Vector2.ZERO)
	if (input_vector != Vector2.ZERO):
		move_and_slide(input_vector * 8 * Engine.iterations_per_second)
		position = position.round()
	

func _save_state() -> Dictionary:
	return {
		position = position
	}

func _load_state(state: Dictionary):
	position = state['position']
