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

func get_drag_activate_area() -> Control:
	return $DragActivateArea
