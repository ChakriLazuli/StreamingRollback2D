extends AgentState
class_name FallState

export(NodePath) var wall_cling_path
onready var _wall_cling: AgentState = get_node(wall_cling_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if change_state(agent, _grounded):
			return
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if change_state(agent, _wall_cling):
			return
	Movement.apply_fall_y(agent, true)
	Movement.apply_drift_x(agent, true)
