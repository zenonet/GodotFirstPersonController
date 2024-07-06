extends ProgressBar

func _ready():
	GameManager.player_health_changed.connect(on_health_changed)

func on_health_changed(health):
	value = health
	visible = health != 100
