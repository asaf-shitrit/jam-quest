extends HBoxContainer

class_name StaminaBar

@export var progress_timer: Timer
@export var max_stamina := 3
@export var stamina:= 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	for i in range(max_stamina):
		var step = ProgressBar.new()

		step.rect_min_size = Vector2(20, 20)
		step.rect_position = Vector2(0, i * 20)
		step.rect_scale = Vector2(1, 1)
		step.value = 0
		step.max_value = progress_timer.wait_time
		step.name = "stamina_step_" + str(i)

		add_child(step)
	

func _process(_delta: float) -> void:
	for i in range(max_stamina):
		var step: ProgressBar = get_node("stamina_step_" + str(i))
		step.value = progress_timer.time_left

		if stamina > i:
			step.value = step.max_value
		else:
			step.value = progress_timer.time_left 
