extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.game_over.connect(on_game_over)
	GameManager.level_completed.connect(on_level_completed)
	hide()

func on_game_over():
	text = "Game Over"
	show()
	$Timer.start()

func on_level_completed():
	text = "You won!"
	show()
	$Timer.start()

func _on_timer_timeout():
	hide()
