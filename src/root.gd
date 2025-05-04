extends Node


@export var debug_mode = false

const match_scene = preload("res://src/match/match.tscn")
const start_menu_scene = preload("res://src/start-menu.tscn")


var active_menu: Control
var current_match: BasketballMatch

func _ready() -> void:
	
	if debug_mode:
		_start_match()
		return
	_show_start_menu()

func _start_match():
	
	var new_match = match_scene.instantiate()
	current_match = new_match
	
	if active_menu:
		remove_child(active_menu)

func _show_start_menu():
	var start_menu = start_menu_scene.instantiate()
	active_menu = start_menu
	add_child(start_menu)
	
func _quit_match():
	
	if current_match:
		remove_child(current_match)
		
	_show_start_menu()
