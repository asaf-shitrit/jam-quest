extends Button

class_name PlayerAvatar

@export var player_data: PlayerData
@export var team: Globals.Team = Globals.Team.None

signal player_pressed(player: PlayerData)

func _ready() -> void:
	$VBoxContainer/Label.text = "%s (%s)" % [player_data.name, player_data.calculate_rating()]
	#$TextureRect.texture = data.character_texture
	
func _process(delta: float) -> void:
	# when not selected opacity is 0.5
	if team == Globals.Team.None:
		modulate.a = 0.5
		$TeamLabel.text = ""
	else:
		modulate.a = 1.0
		$TeamLabel.text = "Team %s" % Utility.get_team_name(team)
		

func _on_pressed() -> void:
	emit_signal("player_pressed", player_data)
