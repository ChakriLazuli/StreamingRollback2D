extends AgentState
class_name WallJumpState

export var jump_reattach_grace_period: int = 10

export(String) var animation_up = "WallJump"
export(String) var animation_down = "WallJumpDown"

export(NodePath) var wall_cling_path
onready var _wall_cling: AgentState = get_node(wall_cling_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var air_dash_path
onready var _air_dash: AgentState = get_node(air_dash_path)

export var drift_max_air: int
export var drift_max_water: int

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if change_state(agent, _grounded):
			return
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if !agent.current_input['jump']:
			if change_state(agent, _wall_cling):
				return
	if !agent.MovementAnimationPlayer.is_playing():
		if change_state(agent, _fall):
			return
	if agent.current_input['dash']:
		if change_state(agent, _air_dash):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
	else:
		agent.drift_max = drift_max_air
	agent.drift_retention_max = agent.drift_max
	
	Movement.apply_fall_y(agent, false)
	Movement.apply_drift_x(agent, true)

func initialize(agent: Agent):
	match agent.attached:
		Enums.AttachSide.RIGHT:
			agent.attach_grace_period_right = jump_reattach_grace_period
			agent.animation_facing = Enums.FacingSide.LEFT
		Enums.AttachSide.LEFT:
			agent.attach_grace_period_left = jump_reattach_grace_period
			agent.animation_facing = Enums.FacingSide.RIGHT
	agent.attached = Enums.AttachSide.NONE
	zero_drift_vars(agent)
	if agent.current_input['y'] > 0:
		agent.MovementAnimationPlayer.play(animation_down)
	else:
		agent.MovementAnimationPlayer.play(animation_up)

func clear_used_vars(agent: Agent):
	agent.reset_animation_y()
	agent.reset_animation_x()
	agent.MovementAnimationPlayer.stop()
	agent.attach_grace_period_left = 0
	agent.attach_grace_period_right = 0
	agent.animation_facing = Enums.FacingSide.NULL
