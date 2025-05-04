extends VBoxContainer

class_name OptionsContainer

enum Option {
	START,
	SETTINGS,
	QUIT
}

signal option_select(option: Option)


func _on_start_button_pressed() -> void:
	emit_signal("option_select", Option.START)


func _on_settings_pressed() -> void:
	emit_signal("option_select", Option.SETTINGS)


func _on_quit_pressed() -> void:
	emit_signal("option_select", Option.QUIT)
