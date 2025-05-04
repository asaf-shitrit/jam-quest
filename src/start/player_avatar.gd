extends Button

class_name PlayerAvatar

@export var player_data: PlayerData
@export var team: Globals.Team = Globals.Team.None

signal player_pressed(player: PlayerData)

func _ready() -> void:
	$VBoxContainer/Label.text = "%s (%s)" % [player_data.name, player_data.calculate_rating()]


	var sprite_sheet = player_data.character_texture
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = sprite_sheet

	# get the first frame of the sprite sheet

	var frame = 0
	var frame_size = Vector2(64, 64) # Assuming each frame is 64x64 pixels
	atlas_texture.region = Rect2(Vector2(frame * frame_size.x, 0), frame_size)

	$VBoxContainer/AspectRatioContainer/Avatar.texture = atlas_texture
	
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
