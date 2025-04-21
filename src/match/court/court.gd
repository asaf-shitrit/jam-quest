extends Node

class_name Court

@export var attack_spots: Array[Spot] = []
@export var defense_spots: Array[Spot] = []
@export var right_basket: Basket
@export var left_basket: Basket

func get_largest_team_size_for_court() -> int:
	return min(attack_spots.size(), defense_spots.size())
