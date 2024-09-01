extends AgentState
class_name GroundedState

export(NodePath) var jump_path
onready var _jump: AgentState = get_node(jump_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var dash_path
onready var _dash: AgentState = get_node(dash_path)

func update(agent: Agent):
	if agent.attached != Enums.AttachSide.DOWN:
		if change_state(agent, _fall):
			return
	if agent.current_input['jump']:
		if change_state(agent, _jump):
			return
	if agent.current_input['dash']:
		if change_state(agent, _dash):
			return
	agent.current_velocity.y = 0
	Movement.apply_drift_x(agent, true)
