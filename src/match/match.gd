extends Node

class_name BasketballMatch

signal match_ended(winning_team, score)
signal match_started(starting_team)
signal score(team, points)
signal match_paused
signal match_resumed
signal match_reset
signal turn_change(team)
signal turn_finished()


@export var court: PackedScene

@export var scoreLimit := 21
@export var teamLimit := 1
var teamA_Score := 0
var teamB_Score := 0

var currentTeamTurn: Globals.Team
@export var userControlledTeam: Globals.Team = Globals.Team.A
@export var ball: Basketball


@export var teamA: TeamData
@export var teamB: TeamData

var is_started: bool = false
var is_ended: bool = false
var is_paused: bool = false

func _ready() -> void:
	setup_court()
	start_match()
	
func setup_court():
	var court_node := court.instantiate()
	add_child(court_node)

func score_points(team: Globals.Team, points: int) -> void:

	# Check if the match has started
	if not is_started:
		print("Match has not started yet.")
		return

	# Check if the match has ended
	if is_ended:
		print("Match has already ended.")
		return

	# Check if the points are valid
	if points <= 0:
		print("Invalid points. Must be greater than 0.")
		return
	

	if team == Globals.Team.A:
		teamA_Score += points
	elif team == Globals.Team.B:
		teamB_Score += points
	else:
		print("Invalid team specified for scoring.")

	# Check if the match needs to end
	_check_if_match_needs_to_end()
	# Emit a signal for scoring
	emit_signal("score", team, points)

func reset_match() -> void:
	if is_started:
		print("Match already started.")
		return
	
	is_started = false
	is_ended = false
	is_paused = false

	teamA_Score = 0
	teamB_Score = 0

	# Reset the ball position
	ball.position = Vector2.ZERO

	print("Match reset!")
	emit_signal("match_reset")

func pause_match() -> void:
	if is_paused:
		print("Match already paused.")
		return
	
	is_paused = true
	print("Match paused!")
	emit_signal("match_paused")

func resume_match() -> void:
	if not is_paused:
		print("Match is not paused.")
		return
	
	is_paused = false
	print("Match resumed!")
	emit_signal("match_resumed")

func _check_if_match_needs_to_end():
	if teamA_Score >= scoreLimit:
		end_match(Globals.Team.A)
	elif teamB_Score >= scoreLimit:
		end_match(Globals.Team.B)

func start_match() -> void:
	if is_started:
		print("Match already started.")
		return

	# Randomly assign teams
	var starting_team := get_random_team()
	var captain := get_team_captain(starting_team)

	assert(captain != null, "Captain is null. Ensure players are assigned to teams correctly.")	

	currentTeamTurn = starting_team

	teamA_Score = 0
	teamB_Score = 0

	# Reset the ball position
	ball.position = Vector2.ZERO
	
	is_started = true

	print("Match started!")
	emit_signal("match_started", starting_team)
	
func get_team_captain(team: Globals.Team) -> Player:
	var players = $Players.get_children()

	for player in players:
		if player is Player:
			if player.team == team:
				return player
	return null

func get_random_team() -> Globals.Team:
	var team_i := randi_range(0, 1)
	if team_i == 1:
		return Globals.Team.A
	else:
		return Globals.Team.B
	
func end_match(winner: Globals.Team):
	
	var winnerScore := teamA_Score
	if winner == Globals.Team.B:
		winnerScore = teamB_Score

	emit_signal("match_ended", winner, winnerScore)
	
func _get_winner():
	if not is_ended:
		print("Match has not ended yet.")
		return null

	if teamA_Score > teamB_Score:
		return Globals.Team.A
	elif teamB_Score > teamA_Score:
		return Globals.Team.B
	else:
		return null

func toggle_current_team():
	# Toggle the current team turn
	if currentTeamTurn == Globals.Team.A:
		currentTeamTurn = Globals.Team.B
	else:
		currentTeamTurn = Globals.Team.A

func finish_turn():
	toggle_current_team()
	# Emit a signal for the end of the turn
	emit_signal("turn_finished")
