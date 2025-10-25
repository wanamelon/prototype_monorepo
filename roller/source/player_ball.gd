class_name PlayerBall extends CharacterBody2D

signal finished(points: int)
signal points_changed(old: int, new: int)
signal spawn_item(chance: float)
signal spawn_bounce_pillar(chance: float)

const SNAIL_TRAIL_SCENE: PackedScene = preload("res://source/snail_trail.tscn")

var _random := RandomNumberGenerator.new()
var _speed: float = 1400.0
var _points: int = 0
var _stamina_seconds: float = 8
var _max_stamina := _stamina_seconds
var _items: Array[ItemDef] = []
var _speed_buff_durations: Array[float] = []
var _size_buff_durations: Array[float] = []
var _items_destroyed: int = 0
var _ticks: int = 0
var _dist_since_last_snail_trail: float = 0
@onready var _original_size: float = ($CollisionShape2D.shape as CircleShape2D).radius
@onready var _original_sprite_scale: Vector2 = $Sprite2D.scale

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

var _bounce_off_everything_duration: float = 0.0

func should_bounce_off_everything():
	return _bounce_off_everything_duration > 0

func _physics_process(delta):
	var start_pos := position
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
	
	var size_buff: float = 0
	var new_size_buff_durations: Array[float] = []
	for duration in _speed_buff_durations:
		size_buff += min(4, 4 * duration)
		var decremented = duration - delta
		if decremented > 0:
			new_size_buff_durations.append(decremented)
	var capped_size_buff: float = min(4, size_buff)
	var size_with_buffs: float = _original_size + capped_size_buff
	_size_buff_durations = new_size_buff_durations
	$CollisionShape2D.shape.radius = size_with_buffs
	var og_sprite_radius_px: float = ($Sprite2D.texture.get_size().x / 2) * _original_sprite_scale.x
	var desired_sprite_radius_px: float = og_sprite_radius_px + capped_size_buff
	$Sprite2D.scale = (desired_sprite_radius_px / og_sprite_radius_px) * _original_sprite_scale
	
	_ticks += 1
	_bounce_off_everything_duration -= delta
	if _ticks % 60 == 0:
		for item in _items:
			if item.item_id == ItemDef.ItemId.BOUNCE_OFF_EVERYTHING:
				if _random.randf() < 0.1 and _bounce_off_everything_duration <= 0:
					_bounce_off_everything_duration = 1.0
	
	_dist_since_last_snail_trail += (position - start_pos).length()
	if _dist_since_last_snail_trail > 50:
		for item in _items:
			if item.item_id == ItemDef.ItemId.SNAIL_TRAIL_OF_LEVEL_UP_SLIME:
				var snail_trail: Area2D = SNAIL_TRAIL_SCENE.instantiate()
				snail_trail.top_level = true
				snail_trail.position = global_position
				_dist_since_last_snail_trail = 0
				add_child(snail_trail)
				break
	
	if _ticks % 6 == 0:
		for item in _items:
			if item.item_id == ItemDef.ItemId.SNAIL_TRAIL_OF_LEVEL_UP_SLIME_TIME_BASED:
				var snail_trail: Area2D = SNAIL_TRAIL_SCENE.instantiate()
				snail_trail.top_level = true
				snail_trail.position = global_position
				add_child(snail_trail)
				break

func _process(delta):
	$TextureProgressBar.value = 100.0 * _stamina_seconds / float(_max_stamina)
	$BouncingModeSprite.visible = should_bounce_off_everything()

func on_tile_destroyed():
	_items_destroyed += 1
	for item in _items:
		match item.item_id:
			ItemDef.ItemId.SPEED_BUFF_ON_DESTROY:
				_speed_buff_durations.append(2.5)
			ItemDef.ItemId.SPAWN_BOUNCE_PILLAR:
				spawn_bounce_pillar.emit(1.0)
			ItemDef.ItemId.INCREASE_SIZE:
				if _items_destroyed % 10 == 0 and _size_buff_durations.size() < 4:
					_size_buff_durations.append(1.5)
			_: pass

func give_points(points: int):
	points_changed.emit(_points, _points + points)
	_points += points
