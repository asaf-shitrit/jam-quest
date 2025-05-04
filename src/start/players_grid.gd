extends Control

class_name PlayersGrid

@export var selectable_players: Array[PlayerData]
@export var player_limit: int = 1

var player_avatar_scene = preload("res://src/start/player-avatar.tscn")

signal selection_finished(teamA: TeamData, teamB: TeamData)
signal back_pressed

var teamA: Array[PlayerData] = []
var teamB: Array[PlayerData] = []

func _selecting_team():
	if teamA.size() < teamB.size():
		return Globals.Team.A
	elif teamA.size() > teamB.size():
		return Globals.Team.B
	else:
		return Globals.Team.A
		

func _ready() -> void:
	
	_reset()
	
	# Create and add player avatars to the grid
	for player_data in selectable_players:
		var player_avatar: PlayerAvatar = player_avatar_scene.instantiate()
		player_avatar.connect("player_pressed", _on_player_pressed)
		player_avatar.player_data = player_data
		$VBoxContainer/FlowContainer.add_child(player_avatar)

func _process(_delta: float) -> void:
	for player_avatar in $VBoxContainer/FlowContainer.get_children():
		if player_avatar is PlayerAvatar:
			player_avatar.team = _get_player_team(player_avatar.player_data)

func _show_menu():
	_reset()

func _reset():
	teamA = []
	teamB= []

func _done_selecting():
	return teamA.size() == player_limit and teamB.size() == player_limit

func _get_player_team(player: PlayerData):
	var inTeamA =  teamA.any(func(p: PlayerData): return p.name == player.name)
	
	if inTeamA:
		return Globals.Team.A
	
	var inTeamB = teamB.any(func(p: PlayerData): return p.name == player.name)
	
	if inTeamB:
		return Globals.Team.B
		
	return Globals.Team.None
	

func _already_picked(player: PlayerData):

	var inTeamA =  teamA.any(func(p: PlayerData): return p.name == player.name)
	var inTeamB = teamB.any(func(p: PlayerData): return p.name == player.name)
	
	return inTeamA or inTeamB

func _on_player_pressed(player: PlayerData):
	
	if _already_picked(player):
		# toggle the player
		var team = _get_player_team(player)
		
		if team == Globals.Team.A:
			var index = teamA.find(player)
			teamA.remove_at(index)
		else:
			var index = teamB.find(player)
			teamB.remove_at(index)
			
		return
	
	var team = _selecting_team()
	if team == Globals.Team.A:
		teamA.push_back(player)
	else:
		teamB.push_back(player)
	
	print("team %s selected %s" % [Utility.get_team_name(team), player.name])
		



func _on_back_pressed() -> void:
	
	_reset()
	
	emit_signal("back_pressed")


func _on_finish_pressed() -> void:
	if not _done_selecting():
		print("cant finish yet")
		
		
	var teamA_Data = TeamData.new()
	teamA_Data.name = "Team A"
	teamA_Data.players = teamA
	
	var teamB_Data = TeamData.new()
	teamB_Data.name = "Team B"
	teamB_Data.players = teamB
	
	emit_signal("selection_finished", teamA_Data, teamB_Data)
