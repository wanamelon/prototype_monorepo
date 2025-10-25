class_name SnailTrail extends Area2D

var duration_sec: float = 0.5

func _ready():
	get_tree().create_tween().tween_property($Sprite2D, "modulate:a", 0, duration_sec)
	get_tree().create_timer(duration_sec).timeout.connect(self.queue_free)
	$Timer.timeout.connect(self._try_level_up)

func _try_level_up():
	for area in get_overlapping_areas():
		if area.get_parent() is TileObject:
			var tile_obj := area.get_parent() as TileObject
			tile_obj.try_level_up_from_snail_trail(0.025)
