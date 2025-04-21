extends AnimationTree

@export var player: Player
@export var debug := false # disables syncing to real player

@export var on_defense: bool
@export var is_dribbling: bool
@export var in_match: bool
@export var has_ball: bool
@export var is_shooting: bool

@export var change_idle_dribble = true
var ready_time = 0


func _ready() -> void:
	start_timer()
	
func _process(_delta: float) -> void:
	
	if debug:
		return
	
	# sync to actual player
	on_defense = player.is_on_defense()
	is_dribbling = player.is_dribbling
	in_match = player._in_match()
	has_ball = player.has_ball
	is_shooting = player.is_shooting
	

func start_timer():
	$IdleDribbleVarientTimer.wait_time = randi_range(10, 20)
	$IdleDribbleVarientTimer.start()

# helps vary the type of idle dribbles we perform
func _on_dribble_varient_timer_timeout() -> void:
	
	$IdleDribbleVarientTimer.stop()
	
	change_idle_dribble = true
	
	await get_tree().create_timer(1).timeout
	
	change_idle_dribble = false
	
	start_timer()
