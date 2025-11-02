class_name Roller extends ItemSystem.Item

const ROLLER_SCENE: PackedScene = preload("res://source/item/roller.tscn")

@onready var _original_collision_shape := $CharacterBody2D/CollisionShape2D.shape as CircleShape2D
@onready var _original_sprite_scale: Vector2 = $Sprite2D.scale
# TODO: belong inside character body?
var _damage: int = 1
var _speed: float = 400.0
var _bounce_count: int = 0
var _velocity: Vector2
var _stamina_seconds: float = 1
var _max_stamina := _stamina_seconds
var finished := false

static func instance() -> Roller:
	var roller: Roller = ROLLER_SCENE.instantiate()
	var near_diagonal_launch_angle = 45 + (90 * Utils.RNG.randi_range(0, 4)) + Utils.RNG.randf_range(-20, 20)
	roller._velocity = (Vector2(1, 0) * roller._speed).rotated(deg_to_rad(near_diagonal_launch_angle))
	roller.tags = [Tag.ROLLER]
	return roller

func _ready():
	$CharacterBody2D.position = position

func compute_damage_per_hit() -> int:
	var damage_with_buffs: int = _damage
	for effect in status_effects:
		if effect.id == ItemSystem.StatusEffectId.DAMAGE_BUFF:
			damage_with_buffs += int(floor(effect.intensity))
	return damage_with_buffs

func activate(state: MatchState):
	var collision_result: KinematicCollision2D = $CharacterBody2D.move_and_collide(_velocity * state.delta)
	position = $CharacterBody2D.position
	if collision_result:
		_velocity = _velocity.bounce(collision_result.get_normal())
		_velocity = _velocity.rotated(deg_to_rad(Utils.RNG.randf_range(-5, 5)))
		_bounce_count += 1
		$BounceAudioPlayer.play()
		_add_event(ItemSystem.BounceEvent.new(self, ItemSystem.find_parent_item(collision_result.get_collider())))
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
			size_buff_px = min(25, size_buff_px)
	var desired_collider_radius_px: float = _original_collision_shape.radius + size_buff_px
	var current_radius_px: float = $CharacterBody2D/CollisionShape2D.shape.radius
	var diff := desired_collider_radius_px - current_radius_px
	var interpolated_radius_px: float = current_radius_px + sign(diff) * min(abs(diff), 5.0)
	var expanded_collider := CircleShape2D.new()
	expanded_collider.radius = interpolated_radius_px
	if _item_root.is_safe_to_place(expanded_collider, global_position, [$CharacterBody2D]):
		$CharacterBody2D/CollisionShape2D.shape = expanded_collider
		var og_sprite_radius_px: float = ($Sprite2D.texture.get_size().x / 2) * _original_sprite_scale.x
		$Sprite2D.scale = (interpolated_radius_px / og_sprite_radius_px) * _original_sprite_scale

func _process(delta):
	$TextureProgressBar.value = 100.0 * _stamina_seconds / float(_max_stamina)
