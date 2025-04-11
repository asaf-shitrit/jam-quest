extends CenterContainer

class_name ScorePanel

@export var game: BasketballMatch

var label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	label = Label.new()

	# Center the text horizontally and vertically
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	add_child(label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if game.is_started:
		# Update the score label
		label.text = str(game.teamA_Score) + " - " + str(game.teamB_Score)
	else:
		# Show a message indicating the match has not started
		label.text = "0"
