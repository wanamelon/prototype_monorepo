class_name BouncePillar extends Node2D

var hit_points: int = 5

func _ready():
	$Hitbox.body_entered.connect(self._on_body_entered)

func _on_body_entered(body):
	if body is PlayerBall:
		hit_points -= 1
	if hit_points <= 0:
		body.on_tile_destroyed()
		queue_free()
