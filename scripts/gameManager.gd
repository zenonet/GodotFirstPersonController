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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_game_over():
	# print(get_tree().root.get_children().map(func(x): return x.name))

	load_level(0)

func on_level_completed():
	pass

var levels = [
	"res://level1.tscn",
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
