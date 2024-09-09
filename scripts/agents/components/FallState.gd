extends AgentState
class_name FallState

export(NodePath) var wall_cling_path
onready var _wall_cling: AgentState = get_node(wall_cling_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

export(NodePath) var air_dash_path
onready var _air_dash: AgentState = get_node(air_dash_path)

export(NodePath) var jump_path
onready var _jump: AgentState = get_node(jump_path)

export var coyote_frames: int = 6

export var fall_max_air: int
export var fall_max_retention_air: int
export var fall_acceleration_air: int
export var drift_max_air: int
export var drift_max_retention_air: int
export var drift_acceleration_air: int

export var fall_max_water: int
export var fall_acceleration_water: int
export var drift_max_water: int
export var drift_acceleration_water: int

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if change_state(agent, _grounded):
			return
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if change_state(agent, _wall_cling):
			return
	if agent.current_input['dash']:
		if change_state(agent, _air_dash):
			return
	if agent.current_input['jump']:
		if agent.frames_in_state < coyote_frames && agent.was_previous_state_grounded():
			agent.position = agent.last_grounded_position
			agent.current_velocity.y = 0
			if change_state(agent, _jump):
				return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
		agent.drift_retention_max = drift_max_water
		agent.drift_acceleration = drift_acceleration_water
		agent.fall_max = fall_max_water
		agent.fall_retention_max = fall_max_water
		agent.fall_acceleration = fall_acceleration_water
	else:
		agent.drift_max = drift_max_air
		agent.drift_retention_max = drift_max_retention_air
		agent.drift_acceleration = drift_acceleration_air
		agent.fall_max = fall_max_air
		agent.fall_retention_max = fall_max_retention_air
		agent.fall_acceleration = fall_acceleration_air
	
	agent.current_input['y'] = 1
	Movement.apply_fall_y(agent, true)
	Movement.apply_drift_x(agent, true)

func initialize(agent: Agent):
	zero_drift_vars(agent)
	zero_fall_vars(agent)
