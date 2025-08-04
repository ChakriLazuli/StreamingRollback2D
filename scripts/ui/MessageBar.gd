extends CanvasLayer
class_name MessageBar

onready var MessageLabel = $Label
onready var MessageTimer = $NetworkTimer

func _ready():
	UiMessageBus.connect("show_message", self, "show_message")
	MessageLabel.visible = false

func show_message(message: String, duration: float):
	MessageLabel.text = message
	MessageLabel.visible = true
	MessageTimer.start(duration * 60)


func _on_NetworkTimer_timeout():
	MessageLabel.visible = false
