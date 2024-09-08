extends AgentState
class_name WalkState

export(NodePath) var jump_path
onready var _jump: AgentState = get_node(jump_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var dash_path
onready var _dash: AgentState = get_node(dash_path)

export(NodePath) var idle_path
onready var _idle: AgentState = get_node(idle_path)

export var drift_max_air: int
export var drift_max_retention_air: int
export var drift_acceleration_air: int

export var drift_max_water: int
export var drift_acceleration_water: int

func update(agent: Agent):
	if agent.current_input['x'] == 0:
		if change_state(agent, _idle):
			return
	if agent.attached != Enums.AttachSide.DOWN:
		if change_state(agent, _fall):
			return
	if agent.current_input['jump']:
		if change_state(agent, _jump):
			return
	if agent.current_input['dash']:
		if change_state(agent, _dash):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
		agent.drift_retention_max = drift_max_water
		agent.drift_acceleration = drift_acceleration_water
	else:
		agent.drift_max = drift_max_air
		agent.drift_retention_max = drift_max_retention_air
		agent.drift_acceleration = drift_acceleration_air
	
	agent.current_velocity.y = 0
	Movement.apply_drift_x(agent, true)

func initialize(agent: Agent):
	agent.SpriteAnimationPlayer.play("walk")
	zero_drift_vars(agent)

func clear_used_vars(agent: Agent):
	agent.SpriteAnimationPlayer.stop()

func is_grounded():
	return true
