extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_play_pressed():
	GameManager.load_level(0)


func _on_quit_pressed():
	get_tree().quit()
