class_name ItemWithPoints extends Node2D

@export var placement_rules: PlacementRules
@export var layer_type: ENUM.Layer
@export var item_type: ENUM.Items
@onready var sprite: Sprite2D = $FishSprite

func get_shape_as_offsets() -> Array[Vector2]:
	var rotated: Array[Vector2] = []
	for child: Node2D in $Points.get_children():
		var raw_position = child.position.rotated(global_rotation)
		rotated.append(raw_position.snapped(Vector2.ONE))
	return rotated

func get_visual_bounding_box() -> Rect2:
	var local_space_bound_box = sprite.get_rect()
	var scaled_local_bb = Rect2(local_space_bound_box) # wrong - doesn't reposition the rect
	scaled_local_bb.size *= sprite.scale
	var global = global_transform * scaled_local_bb
	return $PlacementBoundingBox.get_global_rect()

func get_drag_activate_area() -> Control:
	return $DragActivateArea
