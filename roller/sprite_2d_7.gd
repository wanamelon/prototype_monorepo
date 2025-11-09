extends Sprite2D

@onready var initial_scale := scale
@export var jiggle_frequency: float = 10.0
@export var jiggle_amplitude: float = 0.15

var time_sec: float = Utils.RNG.randf_range(0.0, 2.0)

func _process(delta):
	time_sec += delta
	var coordinate = jiggle_frequency * time_sec
	scale.x = initial_scale.x * (1.0 + jiggle_amplitude * sin(coordinate))
	scale.y = initial_scale.y * (1.0 + jiggle_amplitude * cos((PI / 2.1) + coordinate))
