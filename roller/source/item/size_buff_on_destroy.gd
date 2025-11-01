class_name SizeBuffOnDestroy extends ItemSystem.Item

func activate(state: MatchState):
	for event in state.last_tick_events:
		if event is ItemSystem.DespawnEvent:
			var despawn := event as ItemSystem.DespawnEvent
			if despawn.source is Roller and Utils.RNG.randf() < 10.4:
				_audio_player.play_add_size_buff()
				_add_event(ItemSystem.AddStatusEffect.new(
					ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SIZE_BUFF, 20, 1.5), despawn.source))
