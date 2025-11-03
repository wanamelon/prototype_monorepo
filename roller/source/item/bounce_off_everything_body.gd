class_name BounceBody extends StaticBody2D

var _item_system: ItemSystem

static func instance(item_system: ItemSystem):
	var body = load("res://source/item/bounce_off_everything_body.tscn").instantiate()
	body._item_system = item_system
	return body

func _process(delta):
	$Outline.rotation_degrees += 0.5
	$Outline.visible = not $CollisionShape2D.disabled

func _physics_process(delta):
	if ($CollisionShape2D.disabled
		and _item_system.is_safe_to_place(_collider_circle(), global_position)):
		$CollisionShape2D.disabled = false

func _collider_circle():
	var collider_circle := CircleShape2D.new()
	collider_circle.radius = 63
	return collider_circle
