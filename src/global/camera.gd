extends Camera2D

class_name GameCamera

@export var game: BasketballMatch



var target_zoom = null
var target_position = null

func _ready() -> void:
	zoom = Vector2(5,5)
	position = Vector2(0, -20)

func _process(_delta: float) -> void:
	if target_zoom != null:
		zoom = zoom.lerp(target_zoom, 0.1)

	if target_position != null:
		position = position.lerp(target_position, 0.1)


func _focus_on_game_area():

	var players = game._get_players()

	var center_pos = Vector2.ZERO

	for player in players:
		var pos = player.global_position
		center_pos += pos
	center_pos /= players.size()
	position = center_pos
	
	target_zoom = Vector2(4.5, 4.5)
	target_position = position + Vector2(25, -40)

func _shake(strength: float, duration: float) -> void:
	# Store the original position of the camera
	var original_position = position
	
	# Calculate the end time for the shake
	var end_time = Time.get_ticks_msec() + int(duration * 1000)
	
	while Time.get_ticks_msec() < end_time:
		# Apply a random offset to the camera's position
		var shake_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		position = original_position + shake_offset
		
		# Wait for the next frame
		await get_tree().process_frame
	
	# Reset the camera's position to the original
	position = original_position
