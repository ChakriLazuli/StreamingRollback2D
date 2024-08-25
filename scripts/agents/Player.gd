extends KinematicBody2D

const SPEED_DIVIDER: int = 4
const FPS_MULTIPLIER: int = Engine.iterations_per_second
const DISPLACEMENT_MULTIPLIER: int = FPS_MULTIPLIER / SPEED_DIVIDER

enum AttachSide {NONE, ATTACHED_DOWN, ATTACHED_UP, ATTACHED_RIGHT, ATTACHED_LEFT}
enum FacingSide {RIGHT = 1, LEFT = -1, NULL = 0}

onready var check_down = $CheckDown
onready var check_up = $CheckUp
onready var check_right = $CheckRight
onready var check_left = $CheckLeft
onready var check_water = $CheckWater

onready var MovementAnimationPlayer = $MovementAnimationPlayer
onready var ActionAnimationPlayer = $ActionAnimationPlayer

#Settings
export var fall_max_air: int
export var fall_acceleration_air: int
export var drift_max_air: int
export var drift_acceleration_air: int

export var fall_max_water: int
export var fall_acceleration_water: int
export var drift_max_water: int
export var drift_acceleration_water: int

export var drift_max_ground: int
export var drift_acceleration_ground: int

#Collision
var attached = AttachSide.NONE

#Animation Displacement
export var animation_x: int = 0
export var animation_y: int = 0
export var animation_x_direction = FacingSide.RIGHT
var animation_x_prev: int = 0
var animation_y_prev: int = 0
var animation_x_delta: int = 0
var animation_y_delta: int = 0
#Calculation Only
var animation_x_delta_new: int
var animation_y_delta_new: int
var animation_x_delta_delta: int
var animation_y_delta_delta: int

#Animation Physics
export var actionable: bool = true
export var gravity_on: bool = true
export var drift_max: int = 0
export var drift_acceleration: int = 0
export var fall_max: int = 0
export var fall_acceleration: int = 0

#Processed Physics
var relative_x: int = 0
var relative_y: int = 0

var _facing_direction = FacingSide.RIGHT
var _input_vector: Vector2

func _ready():
	add_to_group('network_sync')

func _get_local_input() -> Dictionary:
	var input := {}
	
	_input_vector = Input.get_vector("0_left", "0_right", "0_up", "0_down")
	input["x"] = int(round(_input_vector.x))
	input["y"] = int(round(_input_vector.y))
	input["jump"] = Input.is_action_pressed("0_jump")
	input["dash"] = Input.is_action_pressed("0_dash")
	input["attack"] = Input.is_action_pressed("0_attack")
	return input

func _network_process(input: Dictionary):	
	_process_animation_step()
	_determine_y_displacement()
	_determine_x_displacement(input)
	
	_handle_actions(input)
	
	_apply_displacement()
	
	_handle_snapping(input)
	_set_movement_params()

func _handle_actions(input: Dictionary):
	if !actionable:
		return
	if attached == AttachSide.ATTACHED_DOWN && input['jump']:
		reset_animation_y()
		reset_animation_x()
		attached = AttachSide.NONE
		MovementAnimationPlayer.play("JumpCurve")
	if attached == AttachSide.ATTACHED_DOWN && input['dash'] && !MovementAnimationPlayer.is_playing():
		reset_animation_x()
		relative_x = 0 
		if input['x'] != 0:
			_facing_direction = input['x']
		animation_x_direction = _facing_direction
		MovementAnimationPlayer.play("DashCurveGround")

func _handle_snapping(input: Dictionary):
	if !input['jump']:
		#_snap_up()
		_snap_right()
		_snap_left()
		_snap_down()

func _snap_down():
	check_down.force_raycast_update()
	if check_down.is_colliding():
		move_and_collide(Vector2(0, 16))
		attached = AttachSide.ATTACHED_DOWN
		
func _snap_up():
	if attached == AttachSide.ATTACHED_DOWN:
		return
	check_up.force_raycast_update()
	if check_up.is_colliding():
		move_and_collide(Vector2(0, -16))
		attached = AttachSide.ATTACHED_UP
		
func _snap_right():
	if attached == AttachSide.ATTACHED_DOWN:
		return
	check_right.force_raycast_update()
	if check_right.is_colliding():
		move_and_collide(Vector2(16, 0))
		attached = AttachSide.ATTACHED_RIGHT
		
func _snap_left():
	if attached == AttachSide.ATTACHED_DOWN:
		return
	check_left.force_raycast_update()
	if check_left.is_colliding():
		move_and_collide(Vector2(-16, 0))
		attached = AttachSide.ATTACHED_LEFT

func _set_movement_params():
	check_water.force_raycast_update()
	if check_water.is_colliding():
		drift_max = drift_max_water
		drift_acceleration = drift_acceleration_water
		fall_max = fall_max_water
		fall_acceleration = fall_acceleration_water
	else:
		drift_max = drift_max_air
		drift_acceleration = drift_acceleration_air
		fall_max = fall_max_air
		fall_acceleration = fall_acceleration_air
	if attached == AttachSide.ATTACHED_DOWN:
		drift_max = drift_max_ground
		drift_acceleration = drift_acceleration_ground

func _restore_defaults():
	actionable = true
	gravity_on = true
	reset_animation_x()
	reset_animation_y()

func reset_animation_x():
	animation_x = 0
	animation_x_prev = 0
	animation_x_delta_new = 0
	animation_x_delta_delta = 0
	animation_x_delta = 0

func reset_animation_y():
	animation_y = 0
	animation_y_prev = 0
	animation_y_delta_new = 0
	animation_y_delta_delta = 0
	animation_y_delta = 0

func _process_animation_step():
	animation_x_delta_new = animation_x - animation_x_prev
	animation_x_delta_delta = animation_x_delta_new - animation_x_delta
	animation_x_delta = animation_x_delta_new
	animation_x_prev = animation_x
	
	animation_y_delta_new = animation_y - animation_y_prev
	animation_y_delta_delta = animation_y_delta_new - animation_y_delta
	animation_y_delta = animation_y_delta_new
	animation_y_prev = animation_y

func _determine_x_displacement(input: Dictionary):
	if attached == AttachSide.ATTACHED_RIGHT || attached == AttachSide.ATTACHED_LEFT:
		relative_x = 0
		return
	relative_x += animation_x_delta_delta * animation_x_direction
	if input['x'] == 0 || sign(-input['x']) == sign(relative_x):
		relative_x = sign(relative_x) * max(abs(relative_x) - drift_acceleration, 0)
	else:
		if abs(relative_x) >= drift_max:
			return
		relative_x += drift_acceleration * input['x']
		relative_x = clamp(relative_x, -drift_max, drift_max)
	if animation_x_delta_delta == 0 && input['x'] != 0:
		_facing_direction = input['x']

func _determine_y_displacement():
	if gravity_on:
		relative_y += fall_acceleration
		relative_y = min(relative_y, fall_max)
	else:
		relative_y = animation_y_delta

func _apply_displacement():
	var displacement = Vector2(relative_x, relative_y)
	move_and_slide(displacement * DISPLACEMENT_MULTIPLIER)
	position = position.round()

func _save_state() -> Dictionary:
	return {
		position = position,
		gravity_on = gravity_on,
		actionable = actionable,
		drift_max = drift_max,
		drift_acceleration = drift_acceleration,
		fall_max = fall_max,
		fall_acceleration = fall_acceleration,
		relative_x = relative_x,
		relative_y = relative_y,
		animation_x = animation_x,
		animation_y = animation_y,
		animation_x_direction = animation_x_direction,
		facing_direction = _facing_direction,
		animation_x_prev = animation_x_prev,
		animation_y_prev = animation_y_prev,
		animation_x_delta = animation_x_delta,
		animation_y_delta = animation_y_delta,
		attached = attached,
	}

func _load_state(state: Dictionary):
	position = state['position']
	gravity_on = state['gravity_on']
	actionable = state['actionable']
	drift_max = state['drift_max']
	drift_acceleration = state['drift_acceleration']
	fall_max = state['fall_max']
	fall_acceleration = state['fall_acceleration']
	relative_x = state['relative_x']
	relative_y = state['relative_y']
	animation_x = state['animation_x']
	animation_y = state['animation_y']
	animation_x_direction = state['animation_x_direction']
	_facing_direction = state['facing_direction']
	animation_x_prev = state['animation_x_prev']
	animation_y_prev = state['animation_y_prev']
	animation_x_delta = state['animation_x_delta']
	animation_y_delta = state['animation_y_delta']
	attached = state['attached']
