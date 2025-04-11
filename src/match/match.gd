extends Node2D

class_name BasketballMatch

signal match_finished(winning_team, score)

@export var scoreLimit := 21
var teamA_Score := 0
var teamB_Score := 0


@export var ball: Basketball

func score(team: Globals.Team, points: int) -> void:
	if team == Globals.Team.A:
		teamA_Score += points
	elif team == Globals.Team.B:
		teamB_Score += points
	else:
		print("Invalid team specified for scoring.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_check_if_match_needs_to_end()
	
	
func _check_if_match_needs_to_end():
	if teamA_Score >= scoreLimit:
		_end_match(Globals.Team.A)
	elif teamB_Score >= scoreLimit:
		_end_match(Globals.Team.B)
	
	
func _end_match(winner: Globals.Team):
	
	var winnerScore := teamA_Score
	if winner == Globals.Team.B:
		winnerScore = teamB_Score

	emit_signal("match_finished", winner, winnerScore)
	
