class_name TileObject extends Node2D

const THOUSANDS_LEVEL_SUFFIXES = ["", "K", "M"]
const LEVEL_COLORS := [
	Color.BLACK, 
	Color.GHOST_WHITE, # Level 1
	Color.GREEN,
	Color.MEDIUM_TURQUOISE, 
	Color.MIDNIGHT_BLUE,
	Color.GOLDENROD,
	Color.ORANGE_RED,
	Color.MEDIUM_VIOLET_RED,
	Color.DARK_VIOLET
]
var rng := RandomNumberGenerator.new()
var level: int = 1

func _ready():
	$Hitbox.body_entered.connect(_on_body_entered)

const DIGITS_PER_THOUSAND_LEVEL: int = 3

func _process(delta):
	var points = 2 ** (level - 1)
	var thousands_level: int = 0
	var normalized: int = points
	while normalized > 1000:
		normalized /= 1000
		thousands_level += 1
	var num_digits = str(points).length()
	$LevelLabel.text = str(normalized) + THOUSANDS_LEVEL_SUFFIXES[thousands_level] # + "\n" + str(points)
	$LevelLabel.set("theme_override_colors/font_color", LEVEL_COLORS[min(len(LEVEL_COLORS)- 1, num_digits)])

func toggle_bounce(should: bool):
	if should:
		var overlap_ball_query = PhysicsShapeQueryParameters2D.new()
		overlap_ball_query.shape = $Hitbox/CollisionShape2D.shape
		overlap_ball_query.transform = global_transform
		overlap_ball_query.collision_mask = 1
		overlap_ball_query.collide_with_areas = false
		var overlaps = get_world_2d().direct_space_state.intersect_shape(overlap_ball_query)
		if overlaps.is_empty():
			$StaticBody2D/CollisionShape2D.disabled = false
	else:
		$StaticBody2D/CollisionShape2D.disabled = true

func _physics_process(delta):
	var expected_seconds_until_growth: float = 4.0 + 8 * log(level)
	var growth_probability_per_second := 1.0 / expected_seconds_until_growth
	if rng.randf() < (delta * growth_probability_per_second):
		$LevelUpAudioPlayer.play()
		level += 1

func try_level_up_from_snail_trail(chance: float):
	if rng.randf() < chance:
		$LevelUpAudioPlayer.play()
		level += 1

func _on_body_entered(body: Node2D):
	if body is PlayerBall:
		var player_ball := body as PlayerBall
		var damage := player_ball.compute_damage_per_hit()
		for i in range(damage):
			if level > 0:
				player_ball.give_points(2 ** (level - 1))
			var expected_growth_sec_base: float = 4.0
			var expected_seconds_until_growth: float = expected_growth_sec_base + 8 * log(level)
			var level_up_chance = player_ball.compute_level_up_on_hit_base_chance() * (expected_growth_sec_base / expected_seconds_until_growth)
			if rng.randf() < level_up_chance:
				$LevelUpAudioPlayer.play()
				level += 1
			else:
				level -= 1
			if level <= 0:
				player_ball.on_tile_destroyed()
				queue_free()
				break
