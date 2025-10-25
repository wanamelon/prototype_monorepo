extends Button

func _ready():
	pressed.connect(func (): $AudioStreamPlayer2D.play())
