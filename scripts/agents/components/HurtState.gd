extends AgentState
class_name HurtState

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export var fall_max_air: int
export var fall_acceleration_air: int

export var fall_max_water: int
export var fall_acceleration_water: int

func update(agent: Agent):
	if agent.frames_in_state > agent.state_timer:
		if change_state(agent, _fall):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.fall_max = fall_max_water
		agent.fall_acceleration = fall_acceleration_water
	else:
		agent.fall_max = fall_max_air
		agent.fall_acceleration = fall_acceleration_air
		
	Movement.apply_fall_y(agent, true)
	Movement.apply_drift_x(agent, false)

func initialize(agent: Agent):
	zero_drift_vars(agent)
	zero_fall_vars(agent)
