extends Node
class_name AgentState

#for states that can have actions overlapping them: 
#let them hold another state that will also update when they do

func update(agent: Agent):
	print("AgentState update not implemented!")

func initialize(agent: Agent):
	pass

func change_state(agent: Agent, new_state: AgentState) -> bool:
	if new_state == null || new_state == self:
		return false
	if !is_available():
		return false
	clear_used_vars(agent)
	agent.SpriteAnimationPlayer.stop()
	agent.MovementAnimationPlayer.stop()
	agent.frames_in_state = 0
	agent.current_state = new_state
	new_state.initialize(agent)
	new_state.update(agent)
	return true

func clear_used_vars(agent: Agent):
	pass

func zero_fall_vars(agent: Agent):
	agent.fall_max = 0
	agent.fall_retention_max = 0
	agent.fall_acceleration = 0

func zero_drift_vars(agent: Agent):
	agent.drift_max = 0
	agent.drift_retention_max = 0
	agent.drift_acceleration = 0

func is_grounded():
	return false

func is_available():
	return true
