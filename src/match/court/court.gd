extends Node

class_name Court

@export var attack_spots: Array[Spot] = []
@export var defense_spots: Array[Spot] = []
@export var right_basket: Basket
@export var left_basket: Basket

signal basket_made(ball)

func _ready():
	if right_basket:
		right_basket.basket_made.connect(_on_basket_made)
	if left_basket:
		left_basket.basket_made.connect(_on_basket_made)



func get_largest_team_size_for_court() -> int:
	return min(attack_spots.size(), defense_spots.size())


func _on_basket_made(ball: Basketball):
	emit_signal("basket_made", ball)
