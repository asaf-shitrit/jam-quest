extends Node2D
class_name Basket

signal basket_made(ball)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Basketball:
		emit_signal("basket_made", body)
	pass # Replace with function body.
	
