extends KinematicBody2D
class_name Agent

onready var MovementAnimationPlayer = $MovementAnimationPlayer
onready var ActionAnimationPlayer = $ActionAnimationPlayer

onready var MomentumHandler = $MomentumHandler
onready var TerrainAttachHandler = $TerrainAttachHandler
onready var MovementParamsHandler = $MovementParamsHandler

onready var check_down = $CheckDown
onready var check_up = $CheckUp
onready var check_right = $CheckRight
onready var check_left = $CheckLeft

const SPEED_DIVIDER: int = 4
const FPS_MULTIPLIER: int = Engine.iterations_per_second
const DISPLACEMENT_MULTIPLIER: int = FPS_MULTIPLIER / SPEED_DIVIDER

var _int_position: Vector2 setget _set_int_position, _get_int_position

func _set_int_position(pos: Vector2):
	var result: Vector2 = pos * SPEED_DIVIDER
	_int_position = result.round()
func _get_int_position():
	return _int_position / SPEED_DIVIDER

export(NodePath) var dual_grid_tile_map_path
onready var tile_map: DualGridTileMap = get_node(dual_grid_tile_map_path)

export(NodePath) var default_state_path
onready var default_state = get_node(default_state_path)

#Collision
var current_tile_type: int = 0
var attached = Enums.AttachSide.NONE

var current_state setget _set_state
var _state_index setget _set_state_index
func _set_state(value):
	current_state = value
	_state_index = current_state.get_index()
func _set_state_index(value):
	_state_index = value
	current_state = get_child(_state_index)

var current_input: Dictionary
var current_velocity: Vector2
var current_momentum: Vector2

#Animation Physics
export var drift_max: int = 0
export var drift_acceleration: int = 0
export var fall_max: int = 0
export var fall_acceleration: int = 0
var facing_direction = Enums.FacingSide.RIGHT

#Animation Displacement
export var animation: Vector2
var animation_prev: Vector2
var animation_delta: Vector2
export var animation_facing = Enums.FacingSide.RIGHT
#Calculation Only
var animation_delta_new: Vector2
var animation_delta_delta: Vector2

var attach_grace_period: int

func _ready():
	add_to_group('network_sync')
	_set_int_position(position)
	_set_state(default_state)

func _network_process(input: Dictionary):
	position = _get_int_position()
	current_input = input
	_update_tile_type()
	TerrainAttachHandler.update_attachment(self)
	_process_animation_step()
	current_state.update(self)
	MomentumHandler.update_momentum(self)
	_apply_displacement()
	_update_tile_type()
	MovementParamsHandler.update_params(self)
	_set_int_position(position)

func _update_tile_type():
	current_tile_type = tile_map.get_tile_type_at_position(global_position)

func _process_animation_step():
	animation_delta_new = animation - animation_prev
	animation_delta_delta = animation_delta_new - animation_delta
	animation_delta = animation_delta_new
	animation_prev = animation

func _apply_displacement():
	var displacement = current_velocity + current_momentum
	if attached == Enums.AttachSide.LEFT || attached == Enums.AttachSide.RIGHT:
		displacement.x = 0
	if attached == Enums.AttachSide.UP || attached == Enums.AttachSide.DOWN:
		displacement.y = 0
	move_and_slide(displacement * DISPLACEMENT_MULTIPLIER)
	current_velocity = current_velocity.round()
	current_momentum = current_momentum.round()

func reset_animation_x():
	animation.x = 0
	animation_prev.x = 0
	animation_delta_new.x = 0
	animation_delta_delta.x = 0
	animation_delta.x = 0

func reset_animation_y():
	animation.y = 0
	animation_prev.y = 0
	animation_delta_new.y = 0
	animation_delta_delta.y = 0
	animation_delta.y = 0


func _save_state() -> Dictionary:
	return {
		_int_position = _int_position,
		drift_max = drift_max,
		drift_acceleration = drift_acceleration,
		fall_max = fall_max,
		fall_acceleration = fall_acceleration,
		current_momentum = current_momentum,
		current_velocity = current_velocity,
		animation = animation,
		animation_facing = animation_facing,
		facing_direction = facing_direction,
		animation_prev = animation_prev,
		animation_delta = animation_delta,
		attached = attached,
		_state_index = _state_index,
	}

func _load_state(state: Dictionary):
	_int_position = state['_int_position']
	drift_max = state['drift_max']
	drift_acceleration = state['drift_acceleration']
	fall_max = state['fall_max']
	fall_acceleration = state['fall_acceleration']
	current_momentum = state['current_momentum']
	current_velocity = state['current_velocity']
	animation = state['animation']
	animation_facing = state['animation_facing']
	facing_direction = state['facing_direction']
	animation_prev = state['animation_prev']
	animation_delta = state['animation_delta']
	attached = state['attached']
	_set_state_index(state['_state_index'])
