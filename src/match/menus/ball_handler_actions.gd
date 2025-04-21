extends Control

class_name BallHandlerActionsMenu


@export var player: Player


func _on_shoot_button_pressed() -> void:
	player.shoot()


func _on_drive_button_pressed() -> void:
	player.drive_to_basket()
