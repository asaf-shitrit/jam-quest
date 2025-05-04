extends Control

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
