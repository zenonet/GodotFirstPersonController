extends Label

func _ready():
	text = "Find and pick up the red briefcase"
	GameManager.briefcase_picked_up.connect(on_briefcase_picked_up)
	
func on_briefcase_picked_up():
	text = "Bring the red briefcase back to the exit"

