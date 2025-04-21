extends HBoxContainer

class_name StaminaBar

@export var player: Player
@export var basketball_texture: Texture2D
@export var full_opacity: float = 0.8
@export var empty_opacity: float = 0.2

var stamina_icons: Array[TextureRect] = []

func _ready() -> void:
	self.add_theme_constant_override("separation", 0)
	_update_stamina_display()


func _process(_delta: float) -> void:
	_update_stamina_display()


func _update_stamina_display() -> void:
	var current_stamina = player.stamina
	var max_stamina = player._get_max_stamina()

	if stamina_icons.size() != max_stamina:
		# Clear and recreate icons
		for icon in stamina_icons:
			remove_child(icon)
			icon.queue_free()
		stamina_icons.clear()

		for i in range(max_stamina):
			var icon = TextureRect.new()
			icon.texture = basketball_texture
			icon.expand = true
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2(12, 12)  # instead of 16x16
			icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			
			add_child(icon)
			stamina_icons.append(icon)

	for i in range(max_stamina):
		stamina_icons[i].modulate.a = full_opacity if i < current_stamina else empty_opacity
