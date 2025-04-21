extends RigidBody2D
class_name Basketball

var game: BasketballMatch
const THREE_POINT_SHOT_DISTANCE = 7.25

enum MissType {
	None,
	Close,
	Airball
}

var did_bounce := false
var post_bounce_velocity := Vector2.ZERO


@export var origin: Vector2
@export var target_basket: Basket
@export var creator: Player
@export var miss_type: MissType = MissType.None

# how long (in seconds) we want the ball to be in flight
@export var time_to_target := 0.85

# physics constants and state
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _initial_velocity := Vector2.ZERO
var _elapsed_time := 0.0
var hit_target := false

func get_modified_target_position() -> Vector2:
	var base_target = target_basket.position
	
	match miss_type:
		MissType.Close:
			# Slightly off (e.g., misses rim but close)
			return base_target + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		MissType.Airball:
			# Way off (e.g., doesn't touch rim)
			return base_target + Vector2(randf_range(-15, 15), randf_range(-5, 5))
		_:
			return base_target

func calculate_projectile_velocity(start: Vector2, target: Vector2, time: float) -> Vector2:
	var dx = target.x - start.x
	var dy = target.y - start.y
	var vx = dx / time
	# solve for initial vy so that y(t)=target.y under constant gravity
	var vy = (dy - 0.5 * gravity * time * time) / time
	return Vector2(vx, vy)

func _ready() -> void:
	# set up collision callback
	connect("body_entered", _on_body_entered)
	# figure out our launch velocity so we land in the hoop in exactly time_to_target
	
	var actual_target = get_modified_target_position()
	_initial_velocity = calculate_projectile_velocity(origin,actual_target, time_to_target)
	_elapsed_time = 0.0
	# start at the origin
	global_position = origin

func _process(delta: float) -> void:
	if miss_type != MissType.None:
		$Body.z_index = 3

	if not origin or not target_basket:
		visible = false
		return
	visible = true

	if did_bounce:
		move_after_bounce(delta)
	elif hit_target:
		move_down(delta)
	else:
		move_in_arc_to_target(delta)



func move_in_arc_to_target(delta: float) -> void:
	_elapsed_time += delta

	var pos = origin \
		+ _initial_velocity * _elapsed_time \
		+ Vector2(0, 0.5 * gravity * _elapsed_time * _elapsed_time)
	global_position = pos

	if _elapsed_time >= time_to_target:
		# Miss: bounce off rim and continue with reduced velocity
		if miss_type != MissType.None:
			did_bounce = true
			post_bounce_velocity = Vector2(_initial_velocity.x * 0.6, -120.0)  # slight upward bounce
		else:
			hit_target = true

		
func move_after_bounce(delta: float) -> void:
	# Apply gravity
	post_bounce_velocity.y += gravity * delta
	global_position += post_bounce_velocity * delta

	# Optionally delete after short time
	if global_position.y > 550:# or any value below the court
		queue_free()


func move_down(delta: float) -> void:

	# once through the hoop, just drop straight down
	# we only need s = ½gt² each frame, but simpler to integrate velocity:
	# v_y += g * dt; y += v_y * dt
	# here we'll just advance by ½gt² so it “snaps” a bit more dramatic:
	global_position.y += 0.6 * gravity * delta * delta
	


func _get_shot_value(distance: float) -> int:
	
	if distance > THREE_POINT_SHOT_DISTANCE:
		return 3
	return 2
	

func _on_body_entered(body: Node) -> void:
	if body is Basket:
		var points := _get_shot_value(origin.distance_to(target_basket.position))
		game.score_points(body.team, points)

		

func _on_turnover_timer_timeout() -> void:
	if not creator:
		push_error("Basketball: no creator assigned for turnover")
		return
	game.turnover(creator)
