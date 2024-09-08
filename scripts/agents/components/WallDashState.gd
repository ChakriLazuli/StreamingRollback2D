extends AgentState
class_name WallDashState

export(String) var animation = "WallDash"

export(NodePath) var wall_cling_path
onready var _wall_cling: AgentState = get_node(wall_cling_path)

export(NodePath) var grounded_path
onready var _grounded: AgentState = get_node(grounded_path)

export(NodePath) var fall_path
onready var _fall: AgentState = get_node(fall_path)

export var fall_max_air: int
export var fall_max_water: int

func update(agent: Agent):
	if agent.attached == Enums.AttachSide.DOWN:
		if change_state(agent, _grounded):
			return
	if agent.attached == Enums.AttachSide.RIGHT || agent.attached == Enums.AttachSide.LEFT:
		if !agent.current_input['jump']:
			if change_state(agent, _wall_cling):
				return
	if !agent.MovementAnimationPlayer.is_playing():
		if change_state(agent, _fall):
			return
	
	if TileData.is_tile_water(agent.current_tile_type):
		agent.fall_max = fall_max_water
	else:
		agent.fall_max = fall_max_air
	agent.fall_retention_max = agent.fall_max
	
	Movement.apply_fall_y(agent, false)
	agent.current_velocity.x = 0

func initialize(agent: Agent):
	agent.reset_animation_y()
	agent.MovementAnimationPlayer.play(animation)
	zero_fall_vars(agent)

func clear_used_vars(agent: Agent):
	agent.reset_animation_y()
	agent.MovementAnimationPlayer.stop()
	agent.attach_grace_period_left = 0
	agent.attach_grace_period_right = 0
	agent.animation_facing = Enums.FacingSide.NULL
