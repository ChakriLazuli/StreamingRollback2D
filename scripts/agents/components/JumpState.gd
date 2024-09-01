extends AgentState
class_name JumpState

export var jump_reattach_grace_period: int = 10

export(NodePath) var wall_cling_path
onready var _wall_cling: AgentState = get_node(wall_cling_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if !agent.current_input['jump']:
			if change_state(agent, _grounded):
				return
		else:
			agent.attached = Enums.AttachSide.NONE
			agent.reset_animation_y()
			agent.MovementAnimationPlayer.play("JumpCurve")
			agent.attach_grace_period = jump_reattach_grace_period
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if change_state(agent, _wall_cling):
			return
	if !agent.MovementAnimationPlayer.is_playing():
		if change_state(agent, _fall):
			return
	Movement.apply_fall_y(agent, false)
	Movement.apply_drift_x(agent, true)

func clear_used_vars(agent: Agent):
	agent.reset_animation_y()
	agent.MovementAnimationPlayer.stop()
	agent.attach_grace_period = 0
