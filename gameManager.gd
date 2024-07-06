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

	get_tree().root.get_node("Root/Region").queue_free()
	await get_tree().physics_frame
	print("Old scene freed")
	var scene = load("res://level1.tscn").instantiate()
	get_tree().root.get_node("Root").add_child(scene)
	scene.name = "Region"

func on_level_completed():
	pass
