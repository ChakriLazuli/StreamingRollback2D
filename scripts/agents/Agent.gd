extends KinematicBody2D
class_name Agent

onready var MovementAnimationPlayer = $MovementAnimationPlayer
onready var ActionAnimationPlayer = $ActionAnimationPlayer
onready var SpriteAnimationPlayer = $SpriteAnimationPlayer

onready var SpriteNode = $Sprite
onready var BubbleNode = $SpriteBubble

onready var MomentumHandler = $MomentumHandler
onready var TerrainAttachHandler = $TerrainAttachHandler
onready var MovementParamsHandler = $MovementParamsHandler
onready var InputBufferer = $InputBufferer

onready var check_down: RayCast2D = $CheckDown
onready var check_up: RayCast2D = $CheckUp
onready var check_right: RayCast2D = $CheckRight
onready var check_left: RayCast2D = $CheckLeft

const SPEED_DIVIDER: int = 4
const FPS_MULTIPLIER: int = Engine.iterations_per_second
const DISPLACEMENT_MULTIPLIER: int = FPS_MULTIPLIER / SPEED_DIVIDER

var _int_position: Vector2 setget _set_int_position, _get_int_position

func _set_int_position(pos: Vector2):
	var result: Vector2 = pos * SPEED_DIVIDER
	_int_position = result.round()
func _get_int_position():
	return _int_position / SPEED_DIVIDER

export(NodePath) var default_state_path
onready var default_state = get_node(default_state_path)

export(NodePath) var hurt_state_path
onready var _hurt_state = get_node(hurt_state_path)

#Collision
var current_tile_type: int = 0
var attached = Enums.AttachSide.NONE
var current_attached_tile_type: int = TileData.Type.AIR

var current_state setget _set_state
var _previous_state_index
var _state_index setget _set_state_index
func _set_state(value):
	_previous_state_index = _state_index
	current_state = value
	_state_index = current_state.get_index()
func _set_state_index(value):
	_previous_state_index = _state_index
	_state_index = value
	current_state = get_child(_state_index)

var current_input: Dictionary
var current_velocity: Vector2
var current_momentum: Vector2

#Animation Physics
export var drift_max: int = 0
export var drift_retention_max: int = 0
export var drift_acceleration: int = 0
export var fall_max: int = 0
export var fall_retention_max: int = 0
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

var attach_grace_period_down: int
var attach_grace_period_right: int
var attach_grace_period_left: int
var attach_grace_period_up: int

var frames_in_state: int
var state_timer: int
var last_grounded_position: Vector2
var air_dashes_left: int

var frames_since_jump_press: int = 60
var frames_since_jump_release: int = 61
var frames_since_dash_press: int = 60
var frames_since_dash_release: int = 61

func _ready():
	add_to_group('network_sync')
	_set_int_position(position)
	_set_state(default_state)
	_previous_state_index = _state_index
	current_state.initialize(self)

func _network_process(input: Dictionary):
	position = _get_int_position()
	current_input = input
	InputBufferer.update_inputs(self)
	frames_in_state += 1
	TerrainAttachHandler.update_attachment(self)
	_update_tile_type()
	_process_animation_step()
	current_state.update(self)
	MomentumHandler.update_momentum(self)
	_apply_displacement()
	_update_tile_type()
	_set_int_position(position)
	_update_sprite_facing()

func _update_sprite_facing():
	match facing_direction:
		Enums.FacingSide.LEFT:
			SpriteNode.scale.x = -1
		Enums.FacingSide.RIGHT:
			SpriteNode.scale.x = 1

func _update_tile_type():
	current_tile_type = TerrainRepository.tile_map.get_tile_type_at_position(global_position)

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

func hurt(frames: int, momentum: Vector2):
	state_timer = frames
	current_momentum += momentum
	current_state.change_state(self, _hurt_state)

func was_previous_state_grounded():
	return get_child(_previous_state_index).is_grounded()

func _save_state() -> Dictionary:
	return {
		_int_position = _int_position,
		drift_max = drift_max,
		drift_retention_max = drift_retention_max,
		drift_acceleration = drift_acceleration,
		fall_max = fall_max,
		fall_retention_max = fall_retention_max,
		fall_acceleration = fall_acceleration,
		current_momentum = current_momentum,
		current_velocity = current_velocity,
		animation = animation,
		animation_facing = animation_facing,
		facing_direction = facing_direction,
		animation_prev = animation_prev,
		animation_delta = animation_delta,
		attached = attached,
		attach_grace_period_down = attach_grace_period_down,
		attach_grace_period_up = attach_grace_period_up,
		attach_grace_period_left = attach_grace_period_left,
		attach_grace_period_right = attach_grace_period_right,
		_state_index = _state_index,
		_previous_state_index = _previous_state_index,
		frames_in_state = frames_in_state,
		state_timer = state_timer,
		last_grounded_position = last_grounded_position,
		air_dashes_left = air_dashes_left,
		frames_since_dash_press = frames_since_dash_press,
		frames_since_dash_release = frames_since_dash_release,
		frames_since_jump_press = frames_since_jump_press,
		frames_since_jump_release = frames_since_jump_release,
	}

func _load_state(state: Dictionary):
	_int_position = state['_int_position']
	drift_max = state['drift_max']
	drift_retention_max = state['drift_retention_max']
	drift_acceleration = state['drift_acceleration']
	fall_max = state['fall_max']
	fall_retention_max = state['fall_retention_max']
	fall_acceleration = state['fall_acceleration']
	current_momentum = state['current_momentum']
	current_velocity = state['current_velocity']
	animation = state['animation']
	animation_facing = state['animation_facing']
	facing_direction = state['facing_direction']
	animation_prev = state['animation_prev']
	animation_delta = state['animation_delta']
	attached = state['attached']
	attach_grace_period_down = state['attach_grace_period_down']
	attach_grace_period_up = state['attach_grace_period_up']
	attach_grace_period_left = state['attach_grace_period_left']
	attach_grace_period_right = state['attach_grace_period_right']
	_set_state_index(state['_state_index'])
	_previous_state_index = state['_previous_state_index']
	frames_in_state = state['frames_in_state']
	state_timer = state['state_timer']
	last_grounded_position = state['last_grounded_position']
	air_dashes_left = state['air_dashes_left']
	frames_since_dash_press = state['frames_since_dash_press']
	frames_since_dash_release = state['frames_since_dash_release']
	frames_since_jump_press = state['frames_since_jump_press']
	frames_since_jump_release = state['frames_since_jump_release']
