class_name BounceOffEverything extends ItemSystem.Item

const BOUNCE_BODY_SCENE: PackedScene = preload("res://source/item/bounce_off_everything_body.tscn")
const BOUNCE_STATIC_BODY_NAME := "BounceOffEverythingBody"

var _bounce_off_everything_duration: float = 0.0

func activate(state: MatchState):
	if state.tick % 60 == 0 and Utils.RNG.randf() < 1.1 and _bounce_off_everything_duration <= 0:
		_bounce_off_everything_duration = 2.5
	if _bounce_off_everything_duration > 0:
		for item in state.items:
			# TODO: only do this for STATIC grid items (or keep it as crop?)!!
			if (item is Crop 
					and not item.has_node(BOUNCE_STATIC_BODY_NAME)
					and not _would_overlap_existing_body(item.global_transform)):
				item.add_child(BOUNCE_BODY_SCENE.instantiate())
	else:
		for item in state.items:
			if item is Crop and item.has_node(BOUNCE_STATIC_BODY_NAME):
				item.remove_child(item.get_node(BOUNCE_STATIC_BODY_NAME))
	_bounce_off_everything_duration -= state.delta

func _would_overlap_existing_body(new_body_global_transform: Transform2D):
	var collider_circle := CircleShape2D.new()
	collider_circle.radius = 45
	var overlap_ball_query = PhysicsShapeQueryParameters2D.new()
	overlap_ball_query.shape = collider_circle
	overlap_ball_query.transform = new_body_global_transform
	overlap_ball_query.collision_mask = 1
	overlap_ball_query.collide_with_areas = false
	var overlaps = _item_root.get_world_2d().direct_space_state.intersect_shape(overlap_ball_query)
	return not overlaps.is_empty()
