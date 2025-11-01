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
					and _item_root.is_safe_to_place(_collider_circle(), item.global_position)):
				item.add_child(BOUNCE_BODY_SCENE.instantiate())
	else:
		for item in state.items:
			if item is Crop and item.has_node(BOUNCE_STATIC_BODY_NAME):
				item.remove_child(item.get_node(BOUNCE_STATIC_BODY_NAME))
	_bounce_off_everything_duration -= state.delta

func _collider_circle():
	var collider_circle := CircleShape2D.new()
	collider_circle.radius = 45
	return collider_circle
