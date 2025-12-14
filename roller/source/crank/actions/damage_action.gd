class_name DamageAction extends Actions.Conf

class Handler extends Actions.Handler:
	func handle(action: Conf, item: Items.Item) -> Array[Events.Event]:
		var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
		var damage_event = DamageEvent.new(item, final_stats.damage)
		return [damage_event]
