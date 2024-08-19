extends Node

onready var status_label = $StatusLabel 

func _ready():
	NetworkPeerManager.connect("listen_as_server", self, "_on_listen_as_server")
	NetworkPeerManager.connect("connect_as_client", self, "_on_connect_as_client")
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	#Other useful signals:
	#get_tree().connect("connection_failed", self, "")
	#get_tree().connect("connected_to_server", self, "")
	#get_tree().connect("server_disconnected", self, "")
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")

func _on_listen_as_server():
	status_label.text = "Listening..."

func _on_connect_as_client():
	status_label.text = "Connecting..."

func _on_network_peer_connected(peer_id: int):
	if (get_tree().is_network_server()):
		status_label.text = "Setting Up..."
	else:
		status_label.text = "Connected!"

func _on_network_peer_disconnected(peer_id: int):
	status_label.text = "Disconnected!"

func _on_SyncManager_sync_started():
	status_label.text = "Running..."

func _on_SyncManager_sync_lost():
	status_label.text = "Sync Lost!"
	
func _on_SyncManager_sync_regained():
	status_label.text = "Running..."

func _on_SyncManager_sync_error(msg: String):
	status_label.text = "Fatal sync error: " + msg
