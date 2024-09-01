extends Node
class_name MovementParamsHandler

export var fall_max_air: int
export var fall_acceleration_air: int
export var drift_max_air: int
export var drift_acceleration_air: int

export var fall_max_water: int
export var fall_acceleration_water: int
export var drift_max_water: int
export var drift_acceleration_water: int

export var drift_max_ground: int
export var drift_acceleration_ground: int

func _ready():
	pass # Replace with function body.

func update_params(agent: Agent):
	if TileData.is_tile_water(agent.current_tile_type):
		agent.drift_max = drift_max_water
		agent.drift_acceleration = drift_acceleration_water
		agent.fall_max = fall_max_water
		agent.fall_acceleration = fall_acceleration_water
	else:
		agent.drift_max = drift_max_air
		agent.drift_acceleration = drift_acceleration_air
		agent.fall_max = fall_max_air
		agent.fall_acceleration = fall_acceleration_air
	if agent.attached == Enums.AttachSide.DOWN:
		agent.drift_max = drift_max_ground
		agent.drift_acceleration = drift_acceleration_ground
