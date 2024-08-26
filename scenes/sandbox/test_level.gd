extends Node2D

onready var _display_tile_map = $DisplayTileMap
onready var _dual_grid_tile_map = $DualGridTileMap

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	NetworkPeerManager.start_local()
	_dual_grid_tile_map.set_tile_map(_display_tile_map)
	#if NetworkPeerManager.IsWebPlatform:
	#	NetworkPeerManager.start_client()
	#else:
	#	NetworkPeerManager.start_server()

func _on_network_peer_connected(peer_id: int):
	NetworkMasterManager.assign_network_master($Player, true, peer_id)
	#NetworkMasterManager.assign_network_master($Player2, false, peer_id)
