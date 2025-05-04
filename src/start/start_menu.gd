extends Control


signal start_match(_match: BasketballMatch)

var match_scene = preload("res://src/match/match.tscn")

func _ready() -> void:
	_reset()
	
func _reset():
	$CenterContainer/PlayersGrid.visible = false

func _on_options_container_option_select(option: OptionsContainer.Option) -> void:
	# Handle option selection
	if option == OptionsContainer.Option.START:
		$CenterContainer/PlayersGrid.visible = true
		$CenterContainer/OptionsContainer.visible = false
	elif option == OptionsContainer.Option.SETTINGS:
		pass
	elif option == OptionsContainer.Option.QUIT:
		get_tree().quit()


func _on_players_grid_selection_finished(teamA: TeamData, teamB: TeamData) -> void:
	var scene: BasketballMatch = match_scene.instantiate()
	
	scene.teamA = teamA
	scene.teamB = teamB
	
	emit_signal("start_match", scene)
	
