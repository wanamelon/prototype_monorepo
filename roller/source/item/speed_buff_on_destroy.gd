class_name SpeedBuffOnDestroy extends ItemSystem.Item

func activate(state: MatchState):
	for despawn: DespawnEvent in Utils.filter(state.last_tick_events, func(i): return i is DespawnEvent):
		if despawn.source.has_all_tags(Tag.ROLLER) and Utils.RNG.randf() < 0.5:
			_audio_player.play_add_speed_buff()
			_add_event(ItemSystem.AddStatusEffect.new(
				ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SPEED_BUFF, 100, 2.5), despawn.source))
