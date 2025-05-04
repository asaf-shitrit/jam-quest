extends Node

class_name BasketballMatch

signal match_ended(winning_team, score)
signal match_started
signal match_exit
signal score(team, points)
signal match_paused
signal match_resumed
signal match_reset
signal possession_change

enum MatchCourtSize {
	Half,
	Full
}

@export var court_scene: PackedScene
var court_node: Court
@export var camera: GameCamera

@export var scoreLimit := 21
var teamA_Score := 0
var teamB_Score := 0

@export var userControlledTeam: Globals.Team = Globals.Team.A

@export var teamA: TeamData
@export var teamB: TeamData

var is_started: bool = false
var is_ended: bool = false
var is_paused: bool = false

var momentum: float = 0.0

@export var player_scene: PackedScene
@export var disable_turnovers = false

func _ready() -> void:
	setup_court()
	setup_players()
	setup_game_indicators()
	start_match()


func _process(delta: float) -> void:
	
	if Input.is_action_just_released("ui_open_menu"):
		$GameCamera/GamePauseMenu.visible = !$GameCamera/GamePauseMenu.visible
	
func update_players_positions():	
	
	var team_with_ball = get_team_controlling_ball()
	
	if team_with_ball == null:
		return
	
	for i in range(get_team_size()):
		
		var team_player = get_team_players(team_with_ball)[i]
		
		team_player.position = court_node.attack_spots[i].position
		team_player.velocity = Vector2.ZERO
		
		var other_team_player = get_other_team_players(team_with_ball)[i]
		other_team_player.position = court_node.defense_spots[i].position
		other_team_player.velocity = Vector2.ZERO

func get_team_size():
	
	var court_team_limit = court_node.get_largest_team_size_for_court()
	var team_max_available_per_team = min(teamA.players.size(), teamB.players.size())
	
	return min(court_team_limit, team_max_available_per_team)

func setup_players():
	for i in range(get_team_size()):
		var player_a := player_scene.instantiate() as Player
		player_a.game = self
		player_a.team = Globals.Team.A
		player_a.data = teamA.players[i]
		
		if userControlledTeam == Globals.Team.B:
			player_a.hide_stamina = true
		
		$Players.add_child(player_a)
		
		var player_b := player_scene.instantiate() as Player
		player_b.game = self
		player_b.team = Globals.Team.B
		player_b.data = teamB.players[i]
		
		if userControlledTeam == Globals.Team.A:
			player_b.hide_stamina = true
		
		$Players.add_child(player_b)
	
func setup_court():
	court_node = court_scene.instantiate()
	court_node.basket_made.connect(_on_basket_made)
	add_child(court_node)
	
func _on_basket_made(ball: Basketball):
	var points = 2
	score_points(ball.creator.team, points)

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

func setup_game_indicators():
	

	
	var team_label := CurrentTeamLabel.new()
	team_label.game = self
	team_label.position.y = 60
	team_label.position.x = 20
	#add_child(team_label)
	
	var score_panel := ScorePanel.new()
	score_panel.game = self
	score_panel.position.y = -90
	score_panel.position.x = 20
	add_child(score_panel)
	
	
	$GameCamera/GamePauseMenu.visible = false

	

func start_match() -> void:
	if is_started:
		print("Match already started.")
		return

	# Randomly assign teams
	var starting_team := userControlledTeam #get_random_team()
	var captain := get_team_captain(starting_team)

	assert(captain != null, "Captain is null. Ensure players are assigned to teams correctly.")

	captain.has_ball = true

	teamA_Score = 0
	teamB_Score = 0
	
	is_started = true

	update_players_positions()
	camera._focus_on_game_area()

	print("Match started!")
	emit_signal("match_started")

func _get_players():
	return $Players.get_children() as Array[Player]
	
func _get_defending_players():
	return _get_players().filter(func (p: Player): return p.is_on_defense())

func get_team_players(team: Globals.Team):
	return _get_players().filter(func (p: Player): return p.team == team)

func get_other_team_players(team: Globals.Team):
	return _get_players().filter(func (p: Player): return p.team != team)
	
func other_team(team: Globals.Team):
	if team == Globals.Team.A:
		return Globals.Team.B
	else:
		return Globals.Team.A

func get_team_captain(team: Globals.Team) -> Player:
	var players = get_team_players(team)
	assert(players.size() >= 1, "team is empty")
	return players[0]

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
	
	
const HALFCOURT_PLAYERS_LIMIT = 3


func _get_player_with_ball_index():
	var players = _get_players()
	var player_with_ball_index = -1

	for i in range(players.size()):
		if players[i].has_ball:
			player_with_ball_index = i
			break

	if player_with_ball_index == -1:
		#print("No player has the ball")
		return -1
		
	return player_with_ball_index

func _get_player_with_ball():
	var index = _get_player_with_ball_index()
	if index == -1:
		return null
	return _get_players()[index]

func get_team_controlling_ball():
	var player = _get_player_with_ball()
	if player == null:
		return null
	return player.team
	
func get_active_basket():
	
	var team_size = max(teamA.players.size(), teamB.players.size())
	
	if team_size <= HALFCOURT_PLAYERS_LIMIT:
		# small teams only halfcourt
		return court_node.right_basket
		
		
	var team_with_ball = get_team_controlling_ball()
	
	if team_with_ball == Globals.Team.A:
		return court_node.right_basket
	elif team_with_ball == Globals.Team.B:
		return court_node.left_basket
	
	return null
	
	
const MIN_DEF_DISTANCE = 100
	
func get_closest_defending_players(to: Player) -> Array[Player]:
	var players: Array[Player] = []
	for player in _get_defending_players():
		if player.position.distance_to(to.position) < MIN_DEF_DISTANCE:
			players.push_back(player)
	return players
	
func turnover(by: Player):
	
	var target_team = other_team(by.team)
	if disable_turnovers:
		target_team = by.team

	var captain = get_team_captain(target_team)
	
	captain.has_ball = true
	emit_signal("possession_change")
	
	update_players_positions()


func _on_leave_match_button_pressed() -> void:
	emit_signal("match_exit")

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
