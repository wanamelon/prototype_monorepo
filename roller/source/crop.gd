class_name Crop extends ItemSystem.Item

"""
What's the bare minimum functionality?
Well, we need the sprite to show up
	Means we also need a crop spawner item!
	Imagine we only care about the round start one
		simple enough. many ways to implement trigger, cheese way is have a state for hasBeenActivated
		as discussed, should create a SpawnEvent, and those are all handled together near frame end by separate code
	For that, we need a way to instance this scene
When player overlaps it, give some points and downlevel -> PointsEvent
	big question: how to represent such an overlap? should I think or just try something?
	I mean definitely we will query player for overlap event(s)
	But from there, we need to figure out which crop it applies to.
	should all that logic be inside our crop class? Or perhaps the player generates not one overlap but multi
	based on which areas it detects etc. And then each one is like Overlap { itemRef, bounce_count, ... }
	or we generate both? eh, in that case it's possible for inconsistent state no?
	I like to have more logic inside individual items to begin, and if we see pattern we can extract. that's flexible
	
	So to sum up:
		player physics event -> return a OverlapEvent(originator, size, etc.)
		in crop tick activate, filter for such events which are from a PlayerBall (or perhaps with a given tags)
		and for each one, we do our downlevel and generate a GivePointsEvent(), play whatever effects
		we'll also maintain some internal state!
	
	hmm ok if there are 2 events level up and level down, but we are at level 0, then order matters
		we would always want to evaluate the level up event first. but that knowledge can live isolated here!
		Fair, don't need a system level solution
It should try and level up each tick, with some percent
	For that, we should create a level up event, but also directly mod our state
	The point of the event is only for triggering other stuff
	If we need to truly "intercept" / change that level up

Stretch (afterwards):
	chance grow on hit
		ideally this lives in a different item entirely?
		that item listens for player overlap events and creates attempt level up events
	enabling player bouncy
	Snail trail
"""

func activate(state: MatchState):
	return [] as Array[ItemEvent]

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

#func _ready():
	#$Hitbox.body_entered.connect(_on_body_entered)

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

#func toggle_bounce(should: bool):
	#if should:
		#var overlap_ball_query = PhysicsShapeQueryParameters2D.new()
		#overlap_ball_query.shape = $Hitbox/CollisionShape2D.shape
		#overlap_ball_query.transform = global_transform
		#overlap_ball_query.collision_mask = 1
		#overlap_ball_query.collide_with_areas = false
		#var overlaps = get_world_2d().direct_space_state.intersect_shape(overlap_ball_query)
		#if overlaps.is_empty():
			#$StaticBody2D/CollisionShape2D.disabled = false
	#else:
		#$StaticBody2D/CollisionShape2D.disabled = true

#func _physics_process(delta):
	#var expected_seconds_until_growth: float = 4.0 + 8 * log(level)
	#var growth_probability_per_second := 1.0 / expected_seconds_until_growth
	#if rng.randf() < (delta * growth_probability_per_second):
		#_level_up()

#func try_level_up_from_snail_trail(chance: float):
	#if rng.randf() < chance:
		#_level_up()
#
#func _level_up():
	#$LevelUpAudioPlayer.play()
	#level = min(20, level + 1)
#
#func _on_body_entered(body: Node2D):
	#if body is PlayerBall:
		#var player_ball := body as PlayerBall
		#var damage := player_ball.compute_damage_per_hit()
		#for i in range(damage):
			#if level > 0:
				#player_ball.give_points(2 ** (level - 1))
			#var expected_growth_sec_base: float = 4.0
			#var expected_seconds_until_growth: float = expected_growth_sec_base + 8 * log(level)
			#var level_up_chance = player_ball.compute_level_up_on_hit_base_chance() * (expected_growth_sec_base / expected_seconds_until_growth)
			#if rng.randf() < level_up_chance:
				#_level_up()
			#else:
				#level -= 1
			#if level <= 0:
				#player_ball.on_tile_destroyed()
				#queue_free()
				#break
