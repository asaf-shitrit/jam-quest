extends PhysicsBody2D
class_name Basketball

var last_shot_distance := 0.0
var last_shot_origin := Vector2.ZERO

const THREE_POINT_SHOT_DISTANCE = 7.25

@export var game: BasketballMatch

func shot(origin: Vector2, target: BasketArea):
	var distance = origin.distance_to(target.position)
	last_shot_distance = distance
	last_shot_origin = origin

	if distance > THREE_POINT_SHOT_DISTANCE:
		print("3-point shot attempted from distance: " + str(distance))
	else:
		print("2-point shot attempted from distance: " + str(distance))

	# Emit a signal or call a method to handle the scoring
	# For example, you might want to call a method on the game object
	game.score_points(target.team, get_last_shot_value())

func _get_shot_value(distance: float) -> int:
	if distance > THREE_POINT_SHOT_DISTANCE:
		return 3
	else:
		return 2

func get_last_shot_value(): 
	return _get_shot_value(last_shot_distance)
		
func _ready() -> void:
	self.connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is BasketArea:
		game.score_points(body.team, get_last_shot_value())
		print("Scored " + str(get_last_shot_value()) + " points for team " + str(body.team))
