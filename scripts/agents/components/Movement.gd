extends Node

func apply_fall_y(agent: Agent, include_acceleration: bool):
	if include_acceleration:
		agent.current_velocity.y += get_adjustment(agent.fall_max - agent.current_velocity.y, agent.fall_acceleration)
	#Bypass maximum for animations
	agent.current_velocity.y += agent.animation_delta_delta.y

func apply_drift_x(agent: Agent, include_acceleration: bool):
	if include_acceleration:
		var drift_direction = agent.current_input['x']
		var diff
		if drift_direction == 0:
			diff = -agent.current_velocity.x
		else:
			diff = agent.drift_max * drift_direction - agent.current_velocity.x
		var acceleration = get_adjustment(diff, sign(diff) * agent.drift_acceleration)
		agent.current_velocity.x += acceleration
	#Bypass maximum for animations
	agent.current_velocity.x += agent.animation_delta_delta.x * agent.animation_facing
	if agent.current_input['x'] != 0:
		agent.facing_direction = agent.current_input['x']

func get_adjustmentv(diff: Vector2, max_adjust: Vector2) -> Vector2:
	return Vector2(get_adjustment(diff.x, max_adjust.x), get_adjustment(diff.y, max_adjust.y))

func get_adjustment(diff: int, max_adjust: int) -> int:
	var maxxed = max(abs(diff), 0)
	var clamped = min(maxxed, max_adjust*sign(diff))
	return int(sign(diff) * clamped)
