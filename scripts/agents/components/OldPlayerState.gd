extends AgentState

var _agent

func update(agent: Agent):
	_agent = agent
	_determine_y_displacement()
	_determine_x_displacement()
	_handle_actions()

func _handle_actions():
	if !_agent.actionable:
		return
	if _agent.attached == Enums.AttachSide.DOWN && _agent.current_input['jump']:
		_agent.reset_animation_y()
		_agent.reset_animation_x()
		_agent.attached = Enums.AttachSide.NONE
		_agent.MovementAnimationPlayer.play("JumpCurve")
	if _agent.attached == Enums.AttachSide.DOWN && _agent.current_input['dash'] && !_agent.MovementAnimationPlayer.is_playing():
		_agent.reset_animation_x()
		_agent.current_velocity.x = 0 
		if _agent.current_input['x'] != 0:
			_agent.facing_direction = _agent.current_input['x']
		_agent.animation_facing = _agent.facing_direction
		_agent.MovementAnimationPlayer.play("DashCurveGround")

func _determine_x_displacement():
	if _agent.attached == Enums.AttachSide.RIGHT || _agent.attached == Enums.AttachSide.LEFT:
		_agent.current_velocity.x = 0
		return
	_agent.current_velocity.x += _agent.animation_delta_delta.x * _agent.animation_facing
	if _agent.current_input['x'] == 0 || sign(-_agent.current_input['x']) == sign(_agent.current_velocity.x):
		_agent.current_velocity.x = sign(_agent.current_velocity.x) * max(abs(_agent.current_velocity.x) - _agent.drift_acceleration, 0)
	else:
		if abs(_agent.current_velocity.x) >= _agent.drift_max:
			return
		_agent.current_velocity.x += _agent.drift_acceleration * _agent.current_input['x']
		_agent.current_velocity.x = clamp(_agent.current_velocity.x, -_agent.drift_max, _agent.drift_max)
	if _agent.animation_delta_delta.x == 0 && _agent.current_input['x'] != 0:
		_agent.facing_direction = _agent.current_input['x']

func _determine_y_displacement():
	if _agent.gravity_on:
		#momentum_y = min(0, momentum_y + 1) #increase fall speed up to normal fall speed
		#excess fall speed should funnel into momentum
		_agent.current_velocity.y += _agent.fall_acceleration
		var excess = _agent.current_velocity.y - _agent.fall_max
		if (excess > 0):
			_agent.current_momentum.y += excess
			_agent.current_momentum.y = min(0, _agent.current_momentum.y)
		_agent.current_velocity.y = min(_agent.current_velocity.y, _agent.fall_max)
	else:
		_agent.current_velocity.y = _agent.animation_delta.y
