extends Resource


var player_stats: Dictionary
var game_stats: Dictionary

func _ready():
	# Initialize player stats
	player_stats = {}
	game_stats = {}

func get_player_stat(player_id: String) -> PlayerGameStats:
	if player_id in player_stats:
		return player_stats[player_id] as PlayerGameStats
	else:
		print("Player ID not found in player stats")
		return null
