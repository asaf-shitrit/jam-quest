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
	
	target_zoom = Vector2(6,6)
	target_position = position + Vector2(0, -50)
