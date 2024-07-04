extends Node

signal sound_created(position:Vector3, volume:float)
signal game_over()
# Called when the node enters the scene tree for the first time.
func _ready():
	game_over.connect(on_game_over())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_game_over():
	get_tree().reload_current_scene()
