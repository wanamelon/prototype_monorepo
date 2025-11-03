class_name BounceOffEverything extends ItemSystem.Item

const BOUNCE_BODY_SCENE: PackedScene = preload("res://source/item/bounce_off_everything_body.tscn")
const BOUNCE_STATIC_BODY_NAME := "BounceOffEverythingBody"

var _bounce_off_everything_duration: float = 0.0
var _items_with_bounce_applied = []

func activate(state: MatchState):
	if state.tick % 60 == 0 and Utils.RNG.randf() < 0.1 and _bounce_off_everything_duration <= 0:
		_bounce_off_everything_duration = 2.5
	if _bounce_off_everything_duration > 0:
		for item in state.items:
			if _items_with_bounce_applied.size() >= 4:
				break
			# TODO: only do this for STATIC grid items (or keep it as crop?)!!
			if (item is Crop and not item.has_node(BOUNCE_STATIC_BODY_NAME)):
				item.add_child(BounceBody.instance(_item_root))
				_items_with_bounce_applied.append(item)
	else:
		for item in state.items:
			if item.has_node(BOUNCE_STATIC_BODY_NAME):
				item.remove_child(item.get_node(BOUNCE_STATIC_BODY_NAME))
		_items_with_bounce_applied.clear()
	_bounce_off_everything_duration -= state.delta
