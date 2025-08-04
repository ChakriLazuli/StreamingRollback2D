extends Node

signal show_message(message, duration)

func show_message(message: String, duration: float):
	emit_signal("show_message", message, duration)
