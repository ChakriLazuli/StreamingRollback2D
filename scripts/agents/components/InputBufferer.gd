extends Node
class_name InputBufferer

export var buffer_size = 6
export var buffer_size_small = 2

func update_inputs(agent: Agent):
	agent.frames_since_dash_press += 1
	agent.frames_since_dash_release += 1
	agent.frames_since_jump_press += 1
	agent.frames_since_jump_release += 1
	if agent.current_input['jump']:
		if agent.frames_since_jump_press > agent.frames_since_jump_release:
			agent.frames_since_jump_press = 0
	else:
		if agent.frames_since_jump_release > agent.frames_since_jump_press:
			agent.frames_since_jump_release = 0
	if agent.current_input['dash']:
		if agent.frames_since_dash_press > agent.frames_since_dash_release:
			agent.frames_since_dash_press = 0
	else:
		if agent.frames_since_dash_release > agent.frames_since_dash_press:
			agent.frames_since_dash_release = 0

func is_within_buffer(agent: Agent, input: String, use_small_buffer: bool) -> bool:
	var buffer = buffer_size
	if use_small_buffer:
		buffer = buffer_size_small
	match input:
		'jump':
			return agent.frames_since_jump_press < buffer && agent.frames_since_jump_press <= agent.frames_since_jump_release
		'dash':
			return agent.frames_since_dash_press < buffer && agent.frames_since_dash_press <= agent.frames_since_dash_release
	return false
