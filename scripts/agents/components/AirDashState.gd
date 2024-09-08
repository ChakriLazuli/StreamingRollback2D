extends AgentState
class_name AirDashState

export(String) var animation_up = "AirDashUp"
export(String) var animation_up_side = "AirDashUpSide"
export(String) var animation_side = "AirDashSide"
export(String) var animation_down_side = "AirDashDownSide"
export(String) var animation_down = "AirDashDown"

export(NodePath) var wall_dash_path
onready var _wall_dash: AgentState = get_node(wall_dash_path)

export(NodePath) var run_path
onready var _run: AgentState = get_node(run_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export var drift_max_air: int
export var drift_max_water: int

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if change_state(agent, _run):
			return
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if !agent.current_input['jump']:
			if change_state(agent, _wall_dash):
				return
	if !agent.MovementAnimationPlayer.is_playing():
		if change_state(agent, _fall):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
	else:
		agent.drift_max = drift_max_air
	agent.drift_retention_max = agent.drift_max
	
	Movement.apply_fall_y(agent, false)
	Movement.apply_drift_x(agent, true)

func initialize(agent: Agent):
	agent.attached = Enums.AttachSide.NONE
	agent.animation_facing = agent.facing_direction
	if agent.current_input['x'] == 0:
		if agent.current_input['y'] > 0:
			agent.MovementAnimationPlayer.play(animation_down)
		else:
			agent.MovementAnimationPlayer.play(animation_up)
	else:
		match int(sign(agent.current_input['y'])):
			0:
				agent.MovementAnimationPlayer.play(animation_side)
			1:
				agent.MovementAnimationPlayer.play(animation_down_side)
			-1:
				agent.MovementAnimationPlayer.play(animation_up_side)
	zero_drift_vars(agent)
	agent.current_velocity.y = 0

func clear_used_vars(agent: Agent):
	agent.reset_animation_y()
	agent.reset_animation_x()
	agent.MovementAnimationPlayer.stop()
	agent.attach_grace_period_left = 0
	agent.attach_grace_period_right = 0
	agent.animation_facing = Enums.FacingSide.NULL
