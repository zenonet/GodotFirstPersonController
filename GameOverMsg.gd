extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.game_over.connect(game_over)
	hide()

func game_over():
	show()
	$Timer.start()

func _on_timer_timeout():
	hide()
