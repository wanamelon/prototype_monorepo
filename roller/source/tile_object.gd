class_name TileObject extends Node2D

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

func _process(delta):
	$LevelLabel.text = str(level)
	$LevelLabel.set("theme_override_colors/font_color", LEVEL_COLORS[min(len(LEVEL_COLORS)- 1, level)])

func _physics_process(delta):
	var expected_seconds_until_growth: float = 4.0 + 8 * log(level)
	var growth_probability_per_second := 1.0 / expected_seconds_until_growth
	if rng.randf() < (delta * growth_probability_per_second):
		level += 1

func _on_body_entered(body: Node2D):
	if body is PlayerBall:
		var player_ball := body as PlayerBall
		if level > 0:
			player_ball.give_points(2 ** (level - 1))
		var expected_growth_sec_base: float = 4.0
		var expected_seconds_until_growth: float = expected_growth_sec_base + 8 * log(level)
		var level_up_chance = player_ball.compute_level_up_on_hit_base_chance() * (expected_growth_sec_base / expected_seconds_until_growth)
		if rng.randf() < level_up_chance:
			level += 1
		else:
			level -= 1
		if level <= 0:
			player_ball.on_tile_destroyed()
			queue_free()
