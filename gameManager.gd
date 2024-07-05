extends Node

signal sound_created(position:Vector3, volume:float)
signal game_over()
signal player_health_changed(newHealth:int)
signal takedown_progress_changed(progress:float)
# Called when the node enters the scene tree for the first time.
func _ready():
	game_over.connect(on_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_game_over():
	# print(get_tree().root.get_children().map(func(x): return x.name))

	get_tree().root.get_node("Root/Region").queue_free()
	await get_tree().physics_frame
	print("Old scene freed")
	var scene = load("res://env.tscn").instantiate()
	get_tree().root.get_node("Root").add_child(scene)
	scene.name = "Region"
