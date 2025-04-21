extends CharacterBody2D

class_name Player

# Locomotion variables
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Gameplay variables
@export var team: Globals.Team
@export var data: PlayerData

# Stamina variables
var stamina: int = 0


@export var game: BasketballMatch
@export var hide_stamina := false


var basketball_scene = preload("res://src/match/basketball/basketball.tscn")

# Match variables
var has_ball: bool = false
var is_dribbling: bool = true

func _ready() -> void:
	_setup_stamina_bar()
	$PlayerTitle.text = "%s" % [data.name]
		
	game.possession_change.connect(_possesion_change_adjustments)
	game.match_started.connect(_possesion_change_adjustments)
	
	$Body.texture = data.character_texture
	
	_adjust_player_direction()

	
func _process(_delta: float) -> void:
	_update_stamina_bar()
	_update_menus_visibility()
	_sync_animation_tree()
	velocity = Vector2.ZERO
	
	
const MAX_STAMINA = 99.0
const MIN_STAMINA = 1.0
const MIN_SECONDS = 3.0
const MAX_SECONDS = 5.0
	
func _get_stamina_wait_time():
	var value := data.stamina
	var t = clamp(inverse_lerp(MIN_STAMINA, MAX_STAMINA, value), 0.0, 1.0)
	return lerp(MIN_SECONDS, MAX_SECONDS, t)


func _setup_stamina_bar():
	$StaminaBar.max_stamina = data.stamina
	$StaminaTimer.one_shot = false
	$StaminaTimer.wait_time = _get_stamina_wait_time()

	if _in_match():
		$StaminaTimer.start()
	else:
		$StaminaTimer.stop()
	

func _update_stamina_bar():
	$StaminaBar.stamina = stamina
	$StaminaBar.visible = not hide_stamina	

func _update_menus_visibility():
	$Menus/BallHandlerMenu.visible = has_ball and not is_on_defense()
	$Menus/OffBallMenu.visible = not has_ball and not is_on_defense()
	
func _sync_animation_tree():
	$AnimationTree.set("parameters/conditions/in_match", _in_match())
	$AnimationTree.set("parameters/Match/conditions/on_defense", is_on_defense())
	$AnimationTree.set("parameters/Match/Offense/conditions/has_ball", has_ball)
	$AnimationTree.set("parameters/Match/Offense/Onball/conditions/is_dribbling", is_dribbling)
	
	
func _physics_process(delta: float) -> void:
	if not _in_match() and not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func drive_to_basket():
	pass

func pass_to_player(player: Player):
	if not has_ball:
		print("Player doesn't have the ball so he can't pass it")
		return
	
	if player == self:
		print("Player can't pass the ball to himself")
		return
	
	if player.team != team:
		print("Player can't pass the ball to an enemy player")
		return
	
	player.has_ball = true
	self.has_ball = false
	

func shoot():
	
	if not has_ball:
		print("Player doesn't have the ball so he can't shoot it")
		return

	if not _in_match():
		print("Player is not in a match")
		return

	# if stamina < 1:
	# 	print("not enough stamina")
	# 	return

	var basket = game.get_active_basket()
	if basket == null:
		print("No active basket")
		return
		
	var bball: Basketball = basketball_scene.instantiate()
	bball.game = game
	bball.origin = position
	bball.target_basket = basket
	bball.creator = self
	game.add_child(bball)

	has_ball = false
	is_dribbling = false
	stamina-=1

func _in_match() -> bool:
	return game != null

func is_on_defense():
	return game.get_team_controlling_ball() != team
		
func _possesion_change_adjustments():
	_adjust_player_direction()
		
func _adjust_player_direction():
	
	var is_flipped = $Body.flip_h
	
	if is_on_defense() and not is_flipped:
		$Body.flip_h = true
	elif not is_on_defense() and is_flipped:
		$Body.flip_h = false	

func _on_stamina_timer_timeout() -> void:
	# replenish stamina
	stamina = min(stamina+1, data.stamina)
