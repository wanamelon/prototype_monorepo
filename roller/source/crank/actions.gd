class_name Actions extends RefCounted

@abstract class ActionHandler extends RefCounted:
	@abstract func handle(action: ActionConf, item: Items.Item) -> Array[Events.GameEvent]

@abstract class ActionConf extends RefCounted:
	pass

class DamageAction extends ActionConf:
	pass

class DamageActionHandler extends ActionHandler:
	func handle(action: ActionConf, item: Items.Item) -> Array[Events.GameEvent]:
		var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
		var damage_event = Events.DamageEvent.new(item, final_stats.damage)
		return [damage_event]

class ActionHandlerManager extends RefCounted:
	var damage_handler: DamageActionHandler

	func _init():
		damage_handler = DamageActionHandler.new()

	func handle(action: ActionConf, item: Items.Item) -> Array[Events.GameEvent]:
		if action is DamageAction:
			return damage_handler.handle(action, item)
		else:
			return []
