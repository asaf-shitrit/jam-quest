extends Control
class_name ActionMenu

@export var player: Player

func _on_button_pressed() -> void:
	emit_signal("pass", player)
