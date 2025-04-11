extends CenterContainer


@export var game: BasketballMatch


var label: Label

func _ready() -> void:
	label = Label.new()
	add_child(label)
	
	game.connect("turn_finished", _sync_team)
	game.connect("match_started", _sync_team)

func _sync_team():
	label.text = "Team %s" % [str(game.currentTeamTurn)]
