class_name SizeBuffOnDestroy extends ItemSystem.Item

func activate(state: MatchState):
	for despawn: DespawnEvent in Utils.filter(state.last_tick_events, func(i): return i is DespawnEvent):
		if despawn.source.has_all_tags(Tag.ROLLER) and Utils.RNG.randf() < 0.4:
			_audio_player.play_add_size_buff()
			_add_event(ItemSystem.AddStatusEffect.new(
				ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SIZE_BUFF, 10, 1.5), despawn.source))
