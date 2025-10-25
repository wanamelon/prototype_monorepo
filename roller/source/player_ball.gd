class_name PlayerBall extends CharacterBody2D

signal finished(points: int)
signal points_changed(old: int, new: int)
signal spawn_item(chance: float)

var _random := RandomNumberGenerator.new()
var _speed: float = 400.0
var _points: int = 0
var _stamina_seconds: float = 8
var _max_stamina := _stamina_seconds
var _items: Array[ItemDef] = []

func scene_init(items: Array[ItemDef]):
	_items = items
	for item in items:
		match item.item_id:
			ItemDef.ItemId.ADD_STAMINA:
				_max_stamina += 1
				_stamina_seconds += 1
			_: pass
	return self

func _ready():
	var near_diagonal_launch_angle = 45 + (90 * _random.randi_range(0, 4)) + _random.randf_range(-20, 20)
	velocity = (Vector2(1, 0) * _speed).rotated(deg_to_rad(near_diagonal_launch_angle))
	points_changed.emit(0, 0)

func compute_level_up_on_hit_base_chance():
	var level_up_chance := 0.0
	for item in _items:
		if item.item_id == ItemDef.ItemId.LEVEL_UP_ITEM_ON_TOUCH:
			level_up_chance = min(1.0, level_up_chance + 0.1)
	return level_up_chance

func _physics_process(delta):
	var collision_result := move_and_collide(velocity * delta)
	if collision_result:
		velocity = velocity.bounce(collision_result.get_normal())
		velocity = velocity.rotated(deg_to_rad(_random.randf_range(-5, 5)))
		var spawn_chance := 0.0
		for item in _items:
			if item.item_id == ItemDef.ItemId.SPAWN_RANDOM_TILE_OBJECT:
				spawn_chance = min(1.0, spawn_chance + 0.2)
		spawn_item.emit(spawn_chance)
	if _stamina_seconds <= 0:
		var damping_factor: float = 4 * velocity.length() * delta
		velocity -= velocity.normalized() * damping_factor
	else:
		var speed_with_buffs := _speed
		var new_speed_buff_durations: Array[float] = []
		for duration in _speed_buff_durations:
			speed_with_buffs += 200 * duration
			var decremented = duration - delta
			if decremented > 0:
				new_speed_buff_durations.append(decremented)
		_stamina_seconds = max(0, _stamina_seconds - delta)
		_speed_buff_durations = new_speed_buff_durations
		velocity = velocity.normalized() * speed_with_buffs
	
	if velocity.length() < 5:
		finished.emit(_points)
		queue_free()

func _process(delta):
	$TextureProgressBar.value = 100.0 * _stamina_seconds / float(_max_stamina)

var _speed_buff_durations: Array[float] = []

func on_tile_destroyed():
	for item in _items:
		match item.item_id:
			ItemDef.ItemId.SPEED_BUFF_ON_DESTROY:
				_speed_buff_durations.append(2.5)
			_: pass

func give_points(points: int):
	points_changed.emit(_points, _points + points)
	_points += points

#func is_near_horizontal(angle_deg: float, horizontal_threshold_deg: float):
	#var deg_from_nearest_horizontal = abs(angle_deg - snapped(angle_deg, 90.0))
	#return deg_from_nearest_horizontal > 5.0
