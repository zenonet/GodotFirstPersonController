extends Node

signal sound_created(position:Vector3, type)
signal game_over()
signal player_health_changed(newHealth:int)
signal takedown_progress_changed(progress:float)
signal level_completed
# Called when the node enters the scene tree for the first time.
func _ready():
	game_over.connect(on_game_over)
	level_completed.connect(on_level_completed)
	set_hud_visibility(false)

func on_game_over():
	load_level(0)

func on_level_completed():
	load_main_menu()

var levels = [
	"res://scenes/level1.tscn",
]

func load_level(id:int):
	var old = get_tree().root.get_node("Root/Region")
	if old != null:
		old.queue_free()
		
	var menu = get_tree().root.get_node("Root/MainMenu")
	if menu != null:
		menu.queue_free()
	await get_tree().physics_frame

	var scene = load(levels[id]).instantiate()
	get_tree().root.get_node("Root").add_child(scene)
	scene.name = "Region"
	set_hud_visibility(true)
	
func load_main_menu():
	var old = get_tree().root.get_node("Root/Region")
	if old != null:
		old.queue_free()
	var scene = load("res://scenes/main_menu.tscn").instantiate()
	get_tree().root.get_node("Root").add_child(scene)
	set_hud_visibility(false)
		
func set_hud_visibility(s):
	var hud = get_tree().root.get_node("Root/UI")
	if hud != null:
		hud.visible = s
