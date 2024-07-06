extends ProgressBar

func _ready():
	hide()
	GameManager.takedown_progress_changed.connect(on_progress_changed)

func on_progress_changed(p:float):
	print("Setting value to %f" % p)
	value = p
	visible = p != -1
