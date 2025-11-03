class_name StatusEffectsLastLonger extends ItemSystem.Item

func intercept_events(events: Array[ItemSystem.ItemEvent]) -> void:
	# TODO: events should be immutable
	for event: ItemSystem.AddStatusEffect in Utils.filter(events, func(e): return e is ItemSystem.AddStatusEffect):
		event.effect.duration_sec *= 1.5
