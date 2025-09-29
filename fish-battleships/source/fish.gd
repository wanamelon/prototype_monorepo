class_name Fish extends Node2D

@onready var colliders = [$GridCollider, $GridCollider2]

func _physics_process(delta: float) -> void:
	for i in range(colliders.size()):
		print("Collider ", i, " has ", colliders[i].get_overlapping_bodies().size())

func _process(delta):
	position = get_viewport().get_mouse_position()
