class_name Crop extends ItemSystem.Item

var last_hit_per_id := {}
var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	for event in state.last_tick_events:
		if event is ItemSystem.FreshOverlapEvent:
			var overlap := event as ItemSystem.FreshOverlapEvent
			# TODO: should not depend on first/second order bruh
			if overlap.first is PlayerBall and overlap.second == self:
				var player := overlap.first as PlayerBall
				for i in range(player.compute_damage_per_hit()):
					events.append(ItemSystem.GivePointsEvent.new(compute_point_value()))
					events.append(ItemSystem.LevelChangeEvent.new(
						-player.compute_damage_per_hit(), 1.0, ItemSystem.SpecificItem.new(self)))
					level -= 1
					if level <= 0:
						player.on_tile_destroyed()
						events.append(ItemSystem.DespawnEvent.new(self))
						break
	# first process all damage events?
	# What's intuitive for the player?
	# Roughly - we should give points = what's on screen
	# thought experiment: super high damage. We should just give sum(level, level-dmg) { level_pts } right?
	# yeah makes sense I guess the simplest thing is think about pairs of level down, level up
	# in that case, we stay at same level, but get points == current
	# so let's make the logic like that. For i in negative change, if there's a positive, cancel it out and give
	# and then add remaining positive at end (play a noise if so)
	var positive_level_change: int = 0
	var negative_level_change: int = 0
	for event in state.last_tick_events:
		if event is ItemSystem.LevelChangeEvent:
			var level_change := event as ItemSystem.LevelChangeEvent
			if (level_change.target is ItemSystem.SpecificItem and level_change.target.target == self):
				if level_change.levels >= 0:
					positive_level_change += level_change.levels
				else:
					negative_level_change += level_change.levels
				#if _random.randf() < level_change.chance:
					#$LevelUpAudioPlayer.play()
					#level = min(20, level + level_change.levels)
	if positive_level_change > 0:
		$LevelUpAudioPlayer.play()
	#for i in range(negative_level_change):
		#events.append(ItemSystem.GivePointsEvent.new(compute_point_value()))
		#if positive_level_change > 0:
			#positive_level_change -= 1
			#continue # cancel out downlevel
		#level -= 1
		#if level <= 0:
			#break
	#if level <= 0:
		#state.player_ball.on_tile_destroyed()
		#events.append(ItemSystem.DespawnEvent.new(self))
	var level_changes_canceled_out: int = min(abs(positive_level_change), abs(negative_level_change))
	for i in range(level_changes_canceled_out):
		events.append(ItemSystem.GivePointsEvent.new(compute_point_value()))
	var net_level_change := positive_level_change + negative_level_change
	if net_level_change > 0:
		level = min(20, level + net_level_change)
	else:
		for i in range(abs(net_level_change)):
			events.append(ItemSystem.GivePointsEvent.new(compute_point_value()))
			level -= 1
			if level <= 0:
				state.player_ball.on_tile_destroyed()
				events.append(ItemSystem.DespawnEvent.new(self))
				break
	return events

func find_parent_item(node: Node) -> ItemSystem.Item:
	var current_node := node
	while not current_node is ItemSystem.Item:
		current_node = current_node.get_parent()
		if current_node == null:
			assert(false, "No item parent for node %s" % node.get_path())
	return current_node

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

func compute_point_value():
	return 2 ** (level - 1)

#func try_level_up_from_snail_trail(chance: float):
	#if rng.randf() < chance:
		#_level_up()

#func _change_level(amount: int):
	#if amount > 0:
		#$LevelUpAudioPlayer.play()
	#level = max(0, min(20, level + amount))

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
