extends AgentState
class_name DashState

export(NodePath) var jump_path
onready var _jump: AgentState = get_node(jump_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

func update(agent: Agent):
	if agent.attached != Enums.AttachSide.DOWN:
		if change_state(agent, _fall):
			return
	if agent.current_input['jump']:
		if change_state(agent, _jump):
			return
	if !agent.MovementAnimationPlayer.is_playing():
		if !agent.current_input['dash']:
			if change_state(agent, _grounded):
				return
		else:
			agent.reset_animation_x()
			agent.current_velocity.x = 0
			agent.animation_facing = agent.facing_direction
			agent.MovementAnimationPlayer.play("DashCurveGround")
	agent.current_velocity.y = 0
	Movement.apply_drift_x(agent, false)

func clear_used_vars(agent: Agent):
	agent.reset_animation_x()
	agent.MovementAnimationPlayer.stop()
