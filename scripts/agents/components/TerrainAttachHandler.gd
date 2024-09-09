extends Node
class_name TerrainAttachHandler

export var dislodge_momentum: int = 20

var _agent: Agent

func update_attachment(agent: Agent):
	_agent = agent
	#_snap_up()
	_snap_right()
	_snap_left()
	_snap_down()
	_update_tile_type()
	if agent.attached == Enums.AttachSide.DOWN:
		agent.last_grounded_position = agent.position

func _update_tile_type():
	match _agent.attached:
		Enums.AttachSide.NONE:
			_agent.current_attached_tile_type = TileData.Type.AIR
		Enums.AttachSide.LEFT:
			_agent.current_attached_tile_type = TerrainRepository.tile_map.get_tile_type_at_position(_agent.check_left.global_position)
		Enums.AttachSide.RIGHT:
			_agent.current_attached_tile_type = TerrainRepository.tile_map.get_tile_type_at_position(_agent.check_right.global_position)
		Enums.AttachSide.UP:
			_agent.current_attached_tile_type = TerrainRepository.tile_map.get_tile_type_at_position(_agent.check_up.global_position)
		Enums.AttachSide.DOWN:
			_agent.current_attached_tile_type = TerrainRepository.tile_map.get_tile_type_at_position(_agent.check_down.global_position)

func _snap_down():
	if (_agent.attach_grace_period_down > 0):
		_agent.attach_grace_period_down = _agent.attach_grace_period_down - 1
		return
	#if _agent.current_input['jump']:
	#	return
	if _agent.current_momentum.y <= -dislodge_momentum:
		if _agent.attached == Enums.AttachSide.DOWN:
			_agent.attached = Enums.AttachSide.NONE
		return
	_agent.check_down.force_raycast_update()
	if _agent.check_down.is_colliding():
		_agent.move_and_collide(Vector2(0, 16))
		_agent.attached = Enums.AttachSide.DOWN
		return
	if _agent.attached == Enums.AttachSide.DOWN:
		_agent.attached = Enums.AttachSide.NONE

func _snap_up():
	if (_agent.attach_grace_period_up > 0):
		_agent.attach_grace_period_up = _agent.attach_grace_period_up - 1
		return
	if _agent.current_input['jump']:
		return
	if !GlobalGameState.is_unlocked('wallcling'):
		return
	if _agent.current_momentum.y >= dislodge_momentum:
		if _agent.attached == Enums.AttachSide.UP:
			_agent.attached = Enums.AttachSide.NONE
		return
	if _agent.attached == Enums.AttachSide.DOWN:
		return
	_agent.check_up.force_raycast_update()
	if _agent.check_up.is_colliding():
		_agent.move_and_collide(Vector2(0, -16))
		_agent.attached = Enums.AttachSide.UP
		return
	if _agent.attached == Enums.AttachSide.UP:
		_agent.attached = Enums.AttachSide.NONE

func _snap_right():
	if (_agent.attach_grace_period_right > 0):
		_agent.attach_grace_period_right = _agent.attach_grace_period_right - 1
		return
	if _agent.current_input['jump']:
		return
	if !GlobalGameState.is_unlocked('wallcling'):
		return
	if _agent.current_momentum.x >= dislodge_momentum:
		if _agent.attached == Enums.AttachSide.RIGHT:
			_agent.attached = Enums.AttachSide.NONE
		return
	if _agent.attached == Enums.AttachSide.DOWN:
		return
	_agent.check_right.force_raycast_update()
	if _agent.check_right.is_colliding():
		_agent.move_and_collide(Vector2(16, 0))
		_agent.attached = Enums.AttachSide.RIGHT
		return
	if _agent.attached == Enums.AttachSide.RIGHT:
		_agent.attached = Enums.AttachSide.NONE

func _snap_left():
	if (_agent.attach_grace_period_left > 0):
		_agent.attach_grace_period_left = _agent.attach_grace_period_left - 1
		return
	if _agent.current_input['jump']:
		return
	if !GlobalGameState.is_unlocked('wallcling'):
		return
	if _agent.current_momentum.x <= -dislodge_momentum:
		if _agent.attached == Enums.AttachSide.LEFT:
			_agent.attached = Enums.AttachSide.NONE
		return
	if _agent.attached == Enums.AttachSide.DOWN:
		return
	_agent.check_left.force_raycast_update()
	if _agent.check_left.is_colliding():
		_agent.move_and_collide(Vector2(-16, 0))
		_agent.attached = Enums.AttachSide.LEFT
		return
	if _agent.attached == Enums.AttachSide.LEFT:
		_agent.attached = Enums.AttachSide.NONE
