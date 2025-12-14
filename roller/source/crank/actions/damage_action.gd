class_name DamageAction extends Actions.ActionHandler

func handle(action: Conf, item: Items.Item) -> Array[Events.GameEvent]:
	var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
	var damage_event = Events.DamageEvent.new(item, final_stats.damage)
	return [damage_event]

class Conf extends Actions.Conf:
	pass
