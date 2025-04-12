extends Node

class_name Court

@export var attack_spots: Array[Node2D] = []
@export var defense_spots: Array[Node2D] = []

func get_largest_team_size_for_court() -> int:
	return min(attack_spots.size(), defense_spots.size())
