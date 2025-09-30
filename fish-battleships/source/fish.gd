class_name Fish extends Node2D

signal fish_placement_attempted(fish: Fish, snapped_viewport_click_position: Vector2)

@onready var colliders: Array[Variant] = [$GridCollider, $GridCollider2]

const GRID_SIZE := Vector2(128, 128)

func _input(event):
	if event.is_action_pressed("PlaceFish"):
		var snapped_click_pos := get_viewport().get_mouse_position().snapped(GRID_SIZE)
		fish_placement_attempted.emit(self, snapped_click_pos)
	elif event.is_action_pressed("RotateFish"):
		rotate(PI / 2)

func _physics_process(delta: float) -> void:
	for i in range(colliders.size()):
		break
		print("Collider ", i, " has ", colliders[i].get_overlapping_bodies().size())

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	position = mouse_pos.snapped(GRID_SIZE)

func get_shape_as_tile_offsets() -> Array[Vector2i]:
	var offsets_at_rest = [Vector2(0, 0), Vector2(1, 0)]
	var rotated: Array[Vector2i] = []
	for offset in offsets_at_rest:
		rotated.append(Vector2i(offset.rotated(transform.get_rotation())))
	return rotated
