class_name Roller extends ItemSystem.Item

const ROLLER_SCENE: PackedScene = preload("res://source/item/roller.tscn")

@onready var _original_collision_shape := $CharacterBody2D/CollisionShape2D.shape as CircleShape2D
@onready var _original_sprite_scale: Vector2 = $Sprite2D.scale
@onready var _original_progress_scale: Vector2 = $Progress/TextureProgressBar.scale
@onready var _original_hitbox_radius: float = $Hitbox/CollisionShape2D.shape.radius
# TODO: belong inside character body?
var _damage := ItemParam.create(1, Tags.of(Tag.P_DAMAGE), ItemParam.clamped(0, 8))
var _speed: float = 400.0
var _bounce_count: int = 0
var _velocity: Vector2
var _stamina_seconds: float = 1.0
var _max_stamina := _stamina_seconds
var finished := false

static func instance() -> Roller:
	var roller: Roller = ROLLER_SCENE.instantiate()
	var near_diagonal_launch_angle = 45 + (90 * Utils.RNG.randi_range(0, 4)) + Utils.RNG.randf_range(-20, 20)
	roller._velocity = (Vector2(1, 0) * roller._speed).rotated(deg_to_rad(near_diagonal_launch_angle))
	return roller

func tags():
	return [Tag.ROLLER, Tag.PROJECTILE] as Array[String]

func params():
	return [_damage] as Array[ItemParam]

func _ready():
	$CharacterBody2D.position = position

func compute_damage_per_hit() -> int:
	return _damage.current.int()

func activate(state: MatchState):
	for impulse: Impulse in Utils.filter(state.last_tick_events, func(i): return (i is Impulse and i.target.matches(self))):
		var speed_sum := impulse.force.length() + _velocity.length()
		var new_vel : Vector2 = (_velocity + impulse.force).normalized() * speed_sum
		_velocity = new_vel
		_add_event(ItemSystem.AddStatusEffect.new(
			ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SPEED_BUFF, impulse.force.length(), 1.5), self))
	var collision_result: KinematicCollision2D = $CharacterBody2D.move_and_collide(_velocity * state.delta)
	position = $CharacterBody2D.position
	if collision_result:
		_velocity = _velocity.bounce(collision_result.get_normal())
		#_velocity = _velocity.rotated(deg_to_rad(Utils.RNG.randf_range(-5, 5)))
		_bounce_count += 1
		$BounceAudioPlayer.play()
		_add_event(ItemSystem.BounceEvent.new(ItemSystem.find_parent_item(collision_result.get_collider())))
	if _stamina_seconds <= 0:
		var damping_factor: float = 4 * _velocity.length() * state.delta
		_velocity -= _velocity.normalized() * damping_factor
		if _velocity.length() < 5:
			finished = true
			_add_event(ItemSystem.DespawnEvent.new(self, self))
	else:
		_apply_speed_buffs()
	_apply_stamina_buffs()
	_apply_size_buffs()
	_stamina_seconds -= state.delta

func _apply_stamina_buffs():
	for effect in status_effects:
		if effect.id == ItemSystem.StatusEffectId.STAMINA_BUFF:
			_stamina_seconds += effect.intensity
			_max_stamina += effect.intensity
			status_effects.erase(effect)

func _apply_speed_buffs():
	var speed_with_buffs := _speed
	for effect in status_effects:
		if effect.id == ItemSystem.StatusEffectId.SPEED_BUFF:
			speed_with_buffs += effect.intensity * min(1, effect.duration_sec)
			speed_with_buffs = min(speed_with_buffs, 10_000)
	_velocity = _velocity.normalized() * speed_with_buffs

func _apply_size_buffs():
	var size_buff_px: float = 0
	for effect in status_effects:
		if effect.id == ItemSystem.StatusEffectId.SIZE_BUFF:
			size_buff_px += effect.intensity * min(1, effect.duration_sec)
			size_buff_px = min((63.9 - _original_collision_shape.radius), size_buff_px)
	var desired_collider_radius_px: float = _original_collision_shape.radius + size_buff_px
	var current_radius_px: float = $CharacterBody2D/CollisionShape2D.shape.radius
	var diff := desired_collider_radius_px - current_radius_px
	var interpolated_radius_px: float = current_radius_px + sign(diff) * min(abs(diff), 5.0)
	var expanded_collider := CircleShape2D.new()
	expanded_collider.radius = interpolated_radius_px
	if _item_root.is_safe_to_place(expanded_collider, global_position, [$CharacterBody2D]):
		$CharacterBody2D/CollisionShape2D.shape = expanded_collider
		var expanded_hitbox := CircleShape2D.new()
		expanded_hitbox.radius = (interpolated_radius_px / _original_collision_shape.radius) * _original_hitbox_radius
		$SpriteHolder.scale = Vector2.ONE * interpolated_radius_px / _original_collision_shape.radius;
		$Hitbox/CollisionShape2D.shape = expanded_hitbox
		var og_sprite_radius_px: float = ($Sprite2D.texture.get_size().x / 2) * _original_sprite_scale.x
		$Sprite2D.scale = (interpolated_radius_px / og_sprite_radius_px) * _original_sprite_scale
		$Progress/TextureProgressBar.scale = (interpolated_radius_px / og_sprite_radius_px) * _original_progress_scale

var scroll_progress: float = 0.0

func _process(delta):
	$Progress/TextureProgressBar.value = 100.0 * _stamina_seconds / float(_max_stamina)
	#var normalized_speed: float = _velocity.length() / 400
	#$SpriteHolder/SpriteSquash.scale.y = clampf(1.0 - 0.2 * log(normalized_speed), 0.1, 1.0)
	$SpriteHolder.rotation = Vector2(0, -1.0).angle_to(_velocity)
	var shader_mat: ShaderMaterial = $SpriteHolder/Scroller.material
	scroll_progress += delta * 1.5 * _velocity.length() / 400
	shader_mat.set_shader_parameter("scroll_progress", scroll_progress)
