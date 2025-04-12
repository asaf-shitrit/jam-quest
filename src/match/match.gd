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


@export var court_scene: PackedScene
var court_node: Court

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
	setup_players()
	start_match()
	update_players_positions()
	
	turn_change.connect(handle_turn_change)
	
func handle_turn_change():
	update_players_positions()
	pass
	
func update_players_positions():
	for i in range(get_team_size()):
		var player_a := $Players/A.get_child(i)
		var player_b := $Players/B.get_child(i)

		if currentTeamTurn == Globals.Team.A:
			player_a.position = court_node.attack_spots[i]
			player_b.position = court_node.defense_spots[i]
		else:
			player_a.position = court_node.defense_spots[i]
			player_b.position = court_node.attack_spots[i]
			

func get_team_size():
	return min(teamA.players.size(), teamB.players.size(), court_node.get_largest_team_size_for_court())

func setup_players():
	for i in range(get_team_size()):
		var player_a := Player.new()
		player_a.team = Globals.Team.A
		player_a.data = teamA.players[i]
		$Players/A.add_child(player_a)
		
		var player_b := Player.new()
		player_b.team = Globals.Team.B
		player_b.data = teamB.players[i]
		$Players/B.add_child(player_b)
	
func setup_court():
	court_node = court_scene.instantiate()
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
		
	# Emit a signal for scoring
	emit_signal("score", team, points)

	# Check if the match needs to end
	_check_if_match_needs_to_end()


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
	
	is_started = true

	print("Match started!")
	emit_signal("match_started", starting_team)
	
func get_team_captain(team: Globals.Team) -> Player:
	if team == Globals.Team.A:
		return $Players/A.get_child(0) as Player
	else:
		return $Players/B.get_child(0) as Player

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
