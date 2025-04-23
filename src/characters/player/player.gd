extends CharacterBody2D

class_name Player

# Locomotion variables
const SPEED = 120
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
var is_shooting = false
var has_ball = false
var is_dribbling = false
var is_driving = false
var selected_defense_type: DefenseType = DefenseType.None

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
	
	
	
	
var arrived_at_basket = false
var has_jumped_at_basket = false  # Make sure to reset this when needed


func _physics_process(delta: float) -> void:
	if not _in_match() and not is_on_floor():
		velocity += get_gravity() * delta

	if is_driving:
		var active_basket = game.get_active_basket()
		if active_basket != null:
			var basket_target = active_basket.position + Vector2(0, 100)
			var stop_distance = 20.0  # How close to get before stopping
			var max_drive_distance = 400.0

			var to_target = basket_target - position
			print("distance to target %d" % to_target.x)
			var distance = to_target.length()

			if distance <= stop_distance:
				# ✅ ARRIVED: stop moving and end drive
				arrived_at_basket = true
				velocity.x = lerp(velocity.x, 0, 0.3)
				
				# ✨ Add a jump when reaching the basket
				if not has_jumped_at_basket:
					velocity.y += -500  # Adjust value based on gravity/jump strength
					has_jumped_at_basket = true
			else:
				# 🏃 Driving toward basket with curved acceleration
				arrived_at_basket = false
				var direction = to_target.normalized()
				var drive_force = SPEED * _drive_curve(distance, max_drive_distance)
				velocity.x = lerp(velocity.x, direction.x * drive_force, 0.1)


	move_and_slide()

func _drive_curve(distance: float, max_distance: float) -> float:
	var t = clamp(distance / max_distance, 0.0, 1.0)
	return 1.0 - pow(t, 2)  # Fast start, slow near basket

	
const MAX_STAMINA = 99.0
const MIN_STAMINA = 1.0
const MIN_SECONDS = 3.0
const MAX_SECONDS = 5.0

const MAX_STAMINA_BARS = 5.0
const MIN_STAMINA_BARS = 3.0
	
func _get_stamina_wait_time():
	var t = clamp(inverse_lerp(MIN_STAMINA, MAX_STAMINA, data.stamina), 0.0, 1.0)
	return lerp(MIN_SECONDS, MAX_SECONDS, t)

func _get_max_stamina():
	var t = clamp(inverse_lerp(MIN_STAMINA, MAX_STAMINA, data.stamina), 0.0, 1.0)
	return lerp(MIN_STAMINA_BARS, MAX_STAMINA_BARS, t)
	

func _setup_stamina_bar():
	print("max stamina %d" % _get_max_stamina())
	$StaminaTimer.one_shot = false
	$StaminaTimer.wait_time = _get_stamina_wait_time()

	if _in_match():
		$StaminaTimer.start()
	else:
		$StaminaTimer.stop()
	

func _update_stamina_bar():
	$StaminaBar.visible = not hide_stamina	

func _update_menus_visibility():
	$Menus/BallHandlerMenu.visible = has_ball
	$Menus/OffBallMenu.visible = game.get_team_controlling_ball() == team and not has_ball
	
func drive_to_basket():
	if not has_ball:
		print("Player doesn't have the ball so he can't drive")
		return
	
	collision_layer = 0
	collision_mask = 0
	z_index = 3
	is_driving = true
	$DriveTimer.start()

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
		
	if stamina < 1:
		print("not enough stamina")
		return

	

	is_shooting = true
	$ShootResetTimer.start()
	await get_tree().create_timer(0.6).timeout
	
	_shoot(PlayerAction.Shoot)


# raw version of shoot used for both layups and jumpers
func _shoot(action: PlayerAction):
	
	assert(action != PlayerAction.Pass, "Passing aint considered a shot")
	
	var basket = game.get_active_basket()
	if basket == null:
		print("No active basket")
		return
	
	var bball: Basketball = basketball_scene.instantiate()
	bball.game = game
	bball.origin = position + Vector2(-1,-20)
	bball.target_basket = basket
	bball.creator = self
	if action == PlayerAction.Shoot:
		bball.shot_type = Basketball.ShotType.Jumper
	elif action == PlayerAction.Drive:
		bball.shot_type = Basketball.ShotType.Layup

	has_ball = false
	is_dribbling = false
	stamina-=1
	$StaminaTimer.start()
	
	# result
	var defending_players = game.get_closest_defending_players(self)
	var action_chance = get_action_result_chance(self, defending_players, action)
	var actual_chance = randf_range(0.0, 100.0)
	
	print("action chance: %d, rolled_chance: %d" % [action_chance, actual_chance])
	
	if actual_chance > action_chance:
		print('missed the shot')
		var delta = absf(actual_chance - action_chance)
		var miss_type = Basketball.MissType.Close
		if delta > 15:
			miss_type = Basketball.MissType.Airball
		bball.miss_type = miss_type
	else:
		print("made the shot")

	
	game.add_child(bball)

func _defense_type():
	return 	DefenseType.Tight

func _in_match() -> bool:
	return game != null

func is_on_defense():
	
	var team_with_ball = game.get_team_controlling_ball()
	
	if team_with_ball == null:
		return false 
	
	return team_with_ball != team
		
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
	stamina += 1
	var max_stamina = _get_max_stamina()
	stamina = clampf(stamina, 0, max_stamina)
	print("stamina %d" % stamina)
	print("max stamina %d" % max_stamina)




const BASE_CHANCE = 40.0 # the chance to hit a general shoot in percent
const BASE_ATT_BONUS = 10.0 # this gives a natural bonus to the attacking side



func sum(accum, number):
	return accum + number


func get_stats_mistatch_on_action(att: Player, def: Array[Player], action: PlayerAction) -> Mismatch:
	
	if def == null:
		return Mismatch.Major
	
	var att_rate = 0
	var def_rate = 0
	if action == PlayerAction.Shoot:
		att_rate = att.data.shooting
	elif action == PlayerAction.Drive:
		att_rate = att.data.finishing
	elif action == PlayerAction.Pass:
		att_rate = att.data.playmaking
	
	for d in def:
		if action == PlayerAction.Shoot:
			def_rate += d.data.perimeter_defense
		elif action == PlayerAction.Drive:
			def_rate += d.data.interior_defense
		elif action == PlayerAction.Pass:
			def_rate += d.data.steal

	
	var delta = (att_rate + BASE_ATT_BONUS) - def_rate
	delta = clampf(delta, 0, 99)
	
	if delta < 5:
		return Mismatch.None
	elif delta < 20:
		return Mismatch.Minor
	else:
		return Mismatch.Major
		
		
func get_stance_mismatch_on_action(att: Player, def: Array[Player], action: PlayerAction) -> Mismatch:
	
	if def == null:
		return Mismatch.Major
		
	if def.all(func (d): d._defense_type() == DefenseType.None):
		return Mismatch.Major # caught off guard
		
	if def.all(func (d): d._defense_type() == DefenseType.Tight) and action == PlayerAction.Drive:
		return Mismatch.Minor # caught off guard
		
	if def.all(func (d): d._defense_type() == DefenseType.Leave) and action == PlayerAction.Shoot:
		return Mismatch.Minor # caught off guard
	
	return Mismatch.None

func get_action_result_chance(att: Player, def: Array[Player], action: PlayerAction):
	
	var chance = BASE_CHANCE
	
	# dry stats phase
	var stats_advantage = get_stats_mistatch_on_action(att, def, action)
	if stats_advantage == Mismatch.Major:
		chance += 10
	elif stats_advantage == Mismatch.Minor:
		chance += 5
		
	# defence stance bonuses phase
	var stance_advantage = get_stance_mismatch_on_action(att, def, action)
	if stance_advantage == Mismatch.Major:
		chance += 10
	elif stance_advantage == Mismatch.Minor:
		chance += 5
	
	# momentum impact
	var relative_momentum = game.momentum
	if team == Globals.Team.B:
		relative_momentum *= -1
	
	# clamp it for safety
	relative_momentum = clampf(relative_momentum, 0, 15)
	
	# add it to chance
	chance += relative_momentum
	
	# final clamp
	chance = clampf(chance, 0, 99.9)
	
	return chance
	
		
enum DefenseType {
	Tight,
	Leave,
	Balanced,
	None
}
	
enum Mismatch {
	Minor,
	Major,
	None
}

enum PlayerAction {
	Shoot,
	Drive,
	Pass
}

enum ActionResult {
	FailedBadly,
	Failed,
	Success
}


func _on_shoot_reset_timer_timeout():
	is_shooting = false
	
func _on_drive_timer_timeout() -> void:
	is_driving = false
	
	collision_layer = 1
	collision_mask = 1
	z_index = 1
	
	_shoot(PlayerAction.Drive)
