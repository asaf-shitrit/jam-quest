extends Node2D
class_name Basket

signal basket_made(ball)

func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body is Basketball:
		emit_signal("basket_made", body)
		await get_tree().create_timer(3).timeout
		if not body.is_queued_for_deletion():
			body.queue_free()

	
	pass # Replace with function body.
