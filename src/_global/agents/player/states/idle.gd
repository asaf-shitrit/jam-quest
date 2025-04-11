extends LimboState


@export var animated_sprite: AnimatedSprite2D
@export var animation_name: StringName


func _enter() -> void:
	animated_sprite.play(animation_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
