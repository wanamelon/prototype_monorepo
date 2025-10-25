class_name BouncePillar extends Node2D

var hit_points: int = 5

func _ready():
	$Hitbox.body_entered.connect(self._on_body_entered)

func can_place(global_pos: Vector2, world_2d):
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = $Hitbox/CollisionShape2D.shape
	query.transform = Transform2D(0, global_pos) 
	query.collision_mask = 1
	query.collide_with_areas = false
	var overlaps = world_2d.direct_space_state.intersect_shape(query)
	return overlaps.is_empty()

func _on_body_entered(body):
	if body is PlayerBall:
		hit_points -= 1
	if hit_points <= 0:
		body.on_tile_destroyed()
		queue_free()
