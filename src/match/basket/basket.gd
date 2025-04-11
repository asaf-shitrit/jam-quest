extends Area2D
class_name BasketArea

signal basketball_entered



@export var team: Team
@export var bballMatch: BasketballMatch 

func _ready() -> void:
	connect("_on_body_entered", _on_body_entered)
	
func _on_body_entered(node: Node):
	if node is Basketball:
		bba
		
		
		
