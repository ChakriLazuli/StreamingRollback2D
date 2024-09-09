extends AgentState
class_name DashState

export(String) var animation = "Dash"

export(NodePath) var jump_path
onready var _jump: AgentState = get_node(jump_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var run_path
onready var _run: AgentState = get_node(run_path)

export var drift_max_air: int
export var drift_max_retention_air: int
export var drift_max_water: int

func update(agent: Agent):
	if agent.attached != Enums.AttachSide.DOWN:
		if change_state(agent, _fall):
			return
	if agent.InputBufferer.is_within_buffer(agent, 'jump', false):
		if change_state(agent, _jump):
			return
	if !agent.MovementAnimationPlayer.is_playing():
		if change_state(agent, _run):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
		agent.drift_retention_max = agent.drift_max
	else:
		agent.drift_max = drift_max_air
		agent.drift_retention_max = drift_max_retention_air
	
	Movement.apply_drift_x(agent, true)

func initialize(agent: Agent):
	agent.reset_animation_x()
	agent.current_velocity.x = 0
	agent.animation_facing = agent.facing_direction
	agent.MovementAnimationPlayer.play(animation)
	zero_drift_vars(agent)
	agent.current_velocity.y = 0

func clear_used_vars(agent: Agent):
	agent.MovementAnimationPlayer.stop()
	agent.animation_facing = Enums.FacingSide.NULL

func is_grounded():
	return true
