extends Node

const LOG_FILE_DIRECTORY = "user://detailed_logs"

var logging_enabled := false

func _ready():
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")

func _on_SyncManager_sync_started():
	if logging_enabled and not SyncReplay.active:
		var dir = Directory.new()
		if not dir.dir_exists(LOG_FILE_DIRECTORY):
			dir.make_dir(LOG_FILE_DIRECTORY)
		
		var datetime = OS.get_datetime(true)
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			multiplayer.get_network_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name) #Can have dictionary with additional info

func _on_SyncManager_sync_stopped():
	if logging_enabled:
		SyncManager.stop_logging()
