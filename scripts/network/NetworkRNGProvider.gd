extends Node

signal rng_seeds_ready()

onready var master_rng = NetworkRandomNumberGenerator.new()

func _ready():
	add_child(master_rng)
	renew()

func renew():
	master_rng.randomize()

func set_seed(target: NetworkRandomNumberGenerator):
	target.set_seed(master_rng.randi()) 

#Potential failure: if the seed changes over time, we must store the original for re-simulation.
func get_master_seed() -> int:
	return master_rng.get_seed()

func set_master_seed(master_seed: int):
	master_rng.set_seed(master_seed)
	emit_signal("rng_seeds_ready")
