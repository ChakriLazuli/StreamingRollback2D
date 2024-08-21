extends Node

signal start_offline()
signal listen_as_server()
signal connect_as_client()
signal stop_networking()
signal set_up_connection()

signal assign_network_masters()

const SERVER_PEER_ID := 1
const DummyNetworkAdapter := preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

const IS_WEB_COMPATIBLE := true

const PORT = 9999
const IP_STRING = "127.0.0.1"

onready var IsWebPlatform := OS.get_name() == "Web"

var _peer = null

func _ready():
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func _on_SyncManager_sync_error(msg: String):
	_close_peer_connection()
	SyncManager.clear_peers()

func _close_peer_connection():
	_peer = get_tree().network_peer
	if !_peer:
		return
	
	if not _peer is WebSocketMultiplayerPeer:
		_peer.close_connection()
		return
	
	if _peer is WebSocketServer:
		_peer.stop()
	if _peer is WebSocketClient:
		_peer.disconnect_from_host()

func _on_network_peer_connected(peer_id: int):
	SyncManager.add_peer(peer_id)
	emit_signal("assign_network_masters")
	
	if get_tree().is_network_server():
		rpc("set_up_connection", {mother_seed = NetworkRngProvider.get_master_seed()})
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()

remotesync func set_up_connection(info: Dictionary):
	NetworkRngProvider.set_master_seed(info['mother_seed'])
	emit_signal("set_up_connection")

func _on_network_peer_disconnected(peer_id: int):
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected():
	_on_network_peer_disconnected(1)

func start_local():
	_initialize_sync_manager(false)
	emit_signal("start_offline")
	SyncManager.start()

func _initialize_sync_manager(online: bool):
	if (online):
		SyncManager.reset_network_adaptor()
	else:
		SyncManager.network_adaptor = DummyNetworkAdapter.new()

func start_server():
	_initialize_sync_manager(true)
	_initialize_server_peer()
	emit_signal("listen_as_server")

func _initialize_server_peer():
	if IS_WEB_COMPATIBLE:
		_peer = WebSocketServer.new()
		_peer.listen(PORT, PoolStringArray(["ludus"]), true)
	else:
		_peer = NetworkedMultiplayerENet.new()
		_peer.create_server(PORT, 1)
	get_tree().set_network_peer(_peer)

func start_client():
	_initialize_sync_manager(true)
	_initialize_client_peer()
	emit_signal("connect_as_client")

func _initialize_client_peer():
	if IS_WEB_COMPATIBLE:
		_peer = WebSocketClient.new()
		_peer.connect_to_url("ws://" + IP_STRING + ":" + str(PORT), PoolStringArray(["ludus"]), true)
	else:
		_peer = NetworkedMultiplayerENet.new()
		_peer.create_client(IP_STRING, PORT)
	get_tree().set_network_peer(_peer)

func reset_network():
	SyncManager.stop()
	SyncManager.clear_peers()
	_close_peer_connection()
	get_tree().reload_current_scene()
	emit_signal("stop_networking")
