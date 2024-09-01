extends Node
class_name TerrainAttachHandler

export var dislodge_momentum: int = 20

var _agent: Agent

func update_attachment(agent: Agent):
	_agent = agent
	if (_agent.attach_grace_period > 0):
		_agent.attach_grace_period = _agent.attach_grace_period - 1
		return
	if _agent.current_input['jump']:
		return
	#_snap_up()
	_snap_right()
	_snap_left()
	_snap_down()

func _snap_down():
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
	if _agent.current_momentum.x <= dislodge_momentum:
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
