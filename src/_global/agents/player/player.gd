extends CharacterBody2D


@export var state_machine: LimboHSM

@onready var idle_state = $LimboHSM/Idle

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


var has_ball: bool = false

func _ready() -> void:
	_initialize_state_machine()
	
func _initialize_state_machine():
	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)

func _physics_process(delta: float) -> void:
	
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	
	move_and_slide()
