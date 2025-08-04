extends AgentState
class_name JumpState

export var jump_reattach_grace_period: int = 10

export(String) var animation = "Jump"

export(NodePath) var wall_cling_path
onready var _wall_cling: AgentState = get_node(wall_cling_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var air_dash_path
onready var _air_dash: AgentState = get_node(air_dash_path)

export var drift_max_air: int
export var drift_max_retention_air: int

export var drift_max_water: int

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if !agent.current_input['jump']:
			if change_state(agent, _grounded):
				return
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if change_state(agent, _wall_cling):
			return
	if !agent.MovementAnimationPlayer.is_playing():
		if change_state(agent, _fall):
			return
	if agent.InputBufferer.is_within_buffer(agent, 'dash', false):
		if change_state(agent, _air_dash):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
		agent.drift_retention_max = drift_max_water
	else:
		agent.drift_max = drift_max_air
		agent.drift_retention_max = drift_max_retention_air
	
	Movement.apply_fall_y(agent, false)
	Movement.apply_drift_x(agent, true)

func initialize(agent: Agent):
	agent.attached = Enums.AttachSide.NONE
	agent.MovementAnimationPlayer.play(animation)
	agent.attach_grace_period_down = jump_reattach_grace_period
	zero_drift_vars(agent)
	agent.current_momentum.y = 0

func clear_used_vars(agent: Agent):
	agent.reset_animation_y()
	agent.MovementAnimationPlayer.stop()
	agent.attach_grace_period_down = 0
	agent.drag_multiplier = 1
