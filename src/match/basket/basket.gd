extends Node2D
class_name Basket

signal basket_made(ball)

func _on_area_2d_body_entered(ball: Node2D) -> void:
	if ball is Basketball:
		ball.freeze = true
		if not ball.did_miss():						
			emit_signal("basket_made", ball)
	pass # Replace with function body.
	
