extends CharacterBody2D

class_name Player

# Locomotion variables
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Gameplay variables
@export var team: Globals.Team

# Stamina variables
@export var stamina_recovery_speed_seconds = 4
@export var max_stamina: int = 3
var stamina: int = max_stamina
@onready var stamina_timer = $StaminaTimer
@onready var stamina_bar: StaminaBar = $StaminaBar

# Match variables
var has_ball: bool = false

func _ready() -> void:
	
	stamina_bar.max_stamina = max_stamina
	stamina_timer.one_shot = false
	stamina_timer.wait_time = stamina_recovery_speed_seconds

	if in_match():
		stamina_timer.start()
	else:
		stamina_timer.stop()

func drive_to_basket(basket: BasketArea):
	pass

func pass_to_player(player: Player):
	pass

func shoot_at_basket(basket: BasketArea):
	pass

func get_current_match() -> BasketballMatch:
	if not owner:
		print("Player has no owner")
		return null
	if not owner is BasketballMatch:
		print("Player's owner is not a BasketballMatch")
		return null
	return owner as BasketballMatch

func in_match() -> bool:
	return get_current_match() != null

func _process(_delta: float) -> void:
	stamina_bar.stamina = stamina
	
func _physics_process(delta: float) -> void:
	if not in_match() and not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()


func _on_stamina_timer_timeout() -> void:
	# replenish stamina
	stamina = min(stamina+1, max_stamina)
