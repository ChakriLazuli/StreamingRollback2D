extends Node
class_name MomentumHandler

export var momentum_decay_rate: int = 1

#Save garbage collection, do not use in parallel
var _tile_type: int
var _tile_momentum: Vector2
var _tile_drag: int
var _momentum_diff: Vector2
var _momentum_adjust: Vector2
var _directed_drag: Vector2
var _agent: Agent

func update_momentum(agent: Agent):
	_agent = agent
	_update_tile_data()
	_update_momentum_drag()
	_update_momentum_attachment()
	#crouching/standing still?

func _update_tile_data():
	_tile_momentum = TileData.get_momentum_for_tile_type(_agent.current_tile_type)
	_tile_drag = TileData.get_drag_for_tile_type(_agent.current_tile_type)

func _update_momentum_drag():
	_momentum_diff = _tile_momentum -_agent.current_momentum
	_directed_drag.x = _tile_drag * sign(_momentum_diff.x)
	_directed_drag.y = _tile_drag * sign(_momentum_diff.y)
	_momentum_adjust = Movement.get_adjustmentv(_momentum_diff, _directed_drag)
	_agent.current_momentum += _momentum_adjust

func _update_momentum_velocity():
	_momentum_diff = _tile_momentum - _agent.current_momentum
	_momentum_adjust = Movement.get_adjustmentv(_momentum_diff, _agent.current_velocity)
	_agent.current_momentum += _momentum_adjust
	_agent.current_velocity -= _momentum_adjust

func _update_momentum_attachment():
	if _agent.attached == Enums.AttachSide.LEFT || _agent.attached == Enums.AttachSide.RIGHT:
		_momentum_diff.x = -_agent.current_momentum.x
		_directed_drag.x = momentum_decay_rate * sign(_momentum_diff.x)
		_momentum_adjust.x = Movement.get_adjustment(_momentum_diff.x, _directed_drag.x)
		_agent.current_momentum.x += _momentum_adjust.x
	if _agent.attached == Enums.AttachSide.UP || _agent.attached == Enums.AttachSide.DOWN:
		_momentum_diff.y = -_agent.current_momentum.y
		_directed_drag.y = momentum_decay_rate * sign(_momentum_diff.y)
		_momentum_adjust.y = Movement.get_adjustment(_momentum_diff.y, _directed_drag.y)
		_agent.current_momentum.y += _momentum_adjust.y
