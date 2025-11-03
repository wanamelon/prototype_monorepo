class_name ExplosiveBarrel extends ItemSystem.Item

func activate(state: MatchState):
	if ($StaticBody2D/CollisionShape2D.disabled
		and _item_root.is_safe_to_place($StaticBody2D/CollisionShape2D.shape, global_position)):
		$StaticBody2D/CollisionShape2D.disabled = false
	# TODO: maybe bounce?
	if not Utils.filter(state.last_tick_events, func (e): return (e is ItemSystem.BounceEvent and e.collided_item.matches(self))).is_empty():
		# for all projectiles
		for projectile: ItemSystem.Item in Utils.filter(state.items, func(i): return i.has_all_tags(Tag.PROJECTILE)):
			var vector_to_projectile := projectile.position - position
			_add_event(ItemSystem.Impulse.new(
				vector_to_projectile,
				1.0,
				projectile
			))
		_audio_player.play_barrel_explode()
		_add_event(ItemSystem.DespawnEvent.new(self, self))
	#for hit: ItemSystem.HitEvent in Utils.filter(state.last_tick_events, func (e): return e is ItemSystem.HitEvent):
		#if hit.aggressor.has_all_tags(Tag.PROJECTILE) and hit.receiver.matches(self):
			## for all projectiles
			#for projectile: ItemSystem.Item in Utils.filter(state.items, func(i): return i.has_all_tags(Tag.PROJECTILE)):
				#var vector_to_projectile := projectile.position - position
				#_add_event(ItemSystem.Impulse.new(
					#vector_to_projectile,
					#1.0,
					#projectile
				#))
			#_audio_player.play_barrel_explode()
			#_add_event(ItemSystem.DespawnEvent.new(self, self))

func tags():
	return [Tag.EXPLOSIVE_BARREL] as Array[String]

class Spawner extends ItemSystem.Item:
	var _level_ups_counter: int = 0
	func activate(state: MatchState):
		var _barrel_count: int = Utils.filter(state.items, func(i): return i.has_all_tags(Tag.EXPLOSIVE_BARREL)).size()
		for level_change: ItemSystem.LevelChangeEvent in Utils.filter(
			state.last_tick_events, func(e): return e is ItemSystem.LevelChangeEvent):
			if (level_change.levels >= 0):
				for i in range(level_change.levels):
					_level_ups_counter += 1
					if _level_ups_counter % 1 == 0 and _barrel_count < 2:
						_add_event(ItemSystem.SpawnEvent.new(
							func (): return load("res://source/item/explosive_barrel.tscn").instantiate(), 
							ItemSystem.AnyFreeCell.new()))
