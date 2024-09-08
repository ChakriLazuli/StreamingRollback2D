extends Node

func apply_fall_y(agent: Agent, include_acceleration: bool):
	if include_acceleration:
		var fall_target = _get_velocity_target(agent.current_input['y'], agent.current_velocity.y, agent.fall_acceleration, agent.fall_max, agent.fall_retention_max)
		agent.current_velocity.y += get_acceleration(agent.current_velocity.y, fall_target, agent.fall_acceleration)
	#Bypass maximum for animations
	agent.current_velocity.y += agent.animation_delta_delta.y

func apply_drift_x(agent: Agent, include_acceleration: bool):
	if include_acceleration:
		var drift_target = _get_velocity_target(agent.current_input['x'], agent.current_velocity.x, agent.drift_acceleration, agent.drift_max, agent.drift_retention_max)
		agent.current_velocity.x += get_acceleration(agent.current_velocity.x, drift_target, agent.drift_acceleration)
	#Bypass maximum for animations
	agent.current_velocity.x += agent.animation_delta_delta.x * agent.animation_facing
	if agent.current_input['x'] != 0:
		agent.facing_direction = agent.current_input['x']

func _get_velocity_target(input: float, velocity: int, acceperation: int, velocity_max: int, retention_max: int) -> int:
	var drift_direction = sign(input)
	if drift_direction == 0:
		return 0
	var directed_velocity = velocity * drift_direction
	if directed_velocity > retention_max:
		return retention_max * drift_direction
	if directed_velocity > velocity_max:
			return int(velocity)
	return velocity_max * drift_direction

func get_acceleration(current: float, target: int, abs_acceleration: int) -> int:
	var diff = target - current
	return get_adjustment(diff, sign(diff) * abs_acceleration)

func get_adjustmentv(diff: Vector2, max_adjust: Vector2) -> Vector2:
	return Vector2(get_adjustment(diff.x, max_adjust.x), get_adjustment(diff.y, max_adjust.y))

func get_adjustment(diff: int, max_adjust: int) -> int:
	var maxxed = max(sign(max_adjust)*diff, 0)
	var clamped = min(maxxed, abs(max_adjust))
	return int(sign(max_adjust) * clamped)
