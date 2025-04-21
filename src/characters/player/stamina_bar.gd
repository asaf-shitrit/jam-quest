extends HBoxContainer

class_name StaminaBar

@export var progress_timer: Timer
@export var max_stamina := 3
@export var stamina:= 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	position = Vector2(-15, 5)

	for i in range(1,max_stamina+1):
		var step = ProgressBar.new()
		
		step.show_percentage = false
		step.custom_minimum_size = Vector2(5, 5)
		step.scale = Vector2(1, 1)
		step.value = 0
		step.max_value = progress_timer.wait_time
		step.name = "stamina_step_" + str(i)

		add_child(step)
	

func _process(_delta: float) -> void:
	for i in range(1,max_stamina+1):
		var step: ProgressBar = get_node("stamina_step_" + str(i))

		if stamina > i:
			step.value = step.max_value
		else:
			step.value = step.max_value - progress_timer.time_left 
			break
