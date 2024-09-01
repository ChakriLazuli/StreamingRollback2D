extends Node
class_name AgentState

func update(agent: Agent):
	print("AgentState update not implemented!")
#for states that can have actions overlapping them: 
#let them hold another state that will also update when they do
func change_state(agent: Agent, new_state: AgentState) -> bool:
	if (new_state == null || new_state == self):
		return false
	clear_used_vars(agent)
	agent.current_state = new_state
	new_state.update(agent)
	return true

func clear_used_vars(agent: Agent):
	pass
