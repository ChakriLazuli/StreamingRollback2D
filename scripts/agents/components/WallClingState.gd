extends AgentState
class_name WallClingState

export var fall_max: int = 1
export var fall_acceleration: int = 6

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var wall_jump_path
onready var _wall_jump: AgentState = get_node(wall_jump_path)

func update(agent: Agent):
	if agent.attached != Enums.AttachSide.RIGHT && agent.attached != Enums.AttachSide.LEFT:
		if change_state(agent, _fall):
			return
	if agent.InputBufferer.is_within_buffer(agent, 'jump', false):
		if change_state(agent, _wall_jump):
			return
	
	agent.fall_acceleration = fall_acceleration
	agent.fall_max = fall_max
	agent.fall_retention_max = agent.fall_max
	
	agent.current_velocity.x = 0
	agent.current_input['y'] = 1
	Movement.apply_fall_y(agent, true)

func initialize(agent: Agent):
	zero_fall_vars(agent)
