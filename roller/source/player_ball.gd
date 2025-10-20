class_name PlayerBall extends CharacterBody2D

signal finished(points: int)
signal points_changed(old: int, new: int)

var _random := RandomNumberGenerator.new()
var _speed: float = 400.0
var _points: int = 0
var _stamina_seconds: float = 8
var _max_stamina := _stamina_seconds
var _random_curve_deg: float = 0

func scene_init(items: Array[ItemDef]):
	for item in items:
		match item.item_id:
			E.ItemId.ADD_STAMINA:
				print("up stamina")
				_max_stamina += 1
				_stamina_seconds += 1
	return self

func _ready():
	var near_diagonal_launch_angle = 45 + (90 * _random.randi_range(0, 4)) + _random.randf_range(-20, 20)
	velocity = (Vector2(1, 0) * _speed).rotated(deg_to_rad(near_diagonal_launch_angle))
	points_changed.emit(0, 0)

func _physics_process(delta):
	var collision_result := move_and_collide(velocity * delta)
	if collision_result:
		velocity = velocity.bounce(collision_result.get_normal())
		_random_curve_deg = _random.randf_range(-10, 10)
	velocity = velocity.rotated(deg_to_rad(_random_curve_deg) * delta)
	_stamina_seconds = max(0, _stamina_seconds - delta)
	if _stamina_seconds <= 0:
		var damping_factor: float = 4 * velocity.length() * delta
		velocity -= velocity.normalized() * damping_factor
	if velocity.length() < 5:
		print("I have reached the ENDE")
		finished.emit(_points)
		queue_free()

func _process(delta):
	$TextureProgressBar.value = 100.0 * _stamina_seconds / float(_max_stamina)

func give_points(points: int):
	points_changed.emit(_points, _points + points)
	_points += points

#func is_near_horizontal(angle_deg: float, horizontal_threshold_deg: float):
	#var deg_from_nearest_horizontal = abs(angle_deg - snapped(angle_deg, 90.0))
	#return deg_from_nearest_horizontal > 5.0
