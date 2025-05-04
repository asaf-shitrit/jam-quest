extends Node


@export var debug_mode = false

const match_scene = preload("res://src/match/match.tscn")
const start_menu_scene = preload("res://src/start/start-menu.tscn")


var active_menu: Control
var current_match: BasketballMatch

func _ready() -> void:
	
	if debug_mode:
		var debug_match = match_scene.instantiate()
		_start_match(debug_match)
		return
	_show_start_menu()

func _start_match(_match: BasketballMatch):
	
	current_match = _match
	
	if active_menu:
		remove_child(active_menu)
		
	current_match.match_exit.connect(_on_match_exit)
	
	add_child(_match)

func _show_start_menu():
	var start_menu = start_menu_scene.instantiate()
	start_menu.z_index = 99
	active_menu = start_menu
	active_menu.start_match.connect(_on_start_match)
	add_child(start_menu)
	
func _on_match_exit():
	assert(current_match != null, "cant exist a null match")

	_show_start_menu()
	
	remove_child(current_match)
	current_match.queue_free()
	
	
	
func _on_start_match(scene: BasketballMatch):
	_start_match(scene)
