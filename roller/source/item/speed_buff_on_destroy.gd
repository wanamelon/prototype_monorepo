class_name SpeedBuffOnDestroy extends ItemSystem.Item

static func instance() -> SpeedBuffOnDestroy:
	return load("res://source/item/speed_buff_on_destroy.tscn").instantiate()

func activate(state: MatchState):
	for event in state.last_tick_events:
		if event is ItemSystem.DespawnEvent:
			var despawn := event as ItemSystem.DespawnEvent
			if despawn.source is Roller and Utils.RNG.randf() < 0.5:
				$AddBuffAudioPlayer.play()
				_add_event(ItemSystem.AddStatusEffect.new(
					ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SPEED_BUFF, 100, 2.5), despawn.source))
