class_name SizeBuffOnDestroy extends ItemSystem.Item

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	for event in state.last_tick_events:
		if event is ItemSystem.DespawnEvent:
			var despawn := event as ItemSystem.DespawnEvent
			if despawn.source is Roller:
				events.append(ItemSystem.AddStatusEffect.new(
					ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.SIZE_BUFF, 15, 11.5), despawn.source))
	return events
