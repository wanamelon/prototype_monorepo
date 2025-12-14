class_name Actions extends RefCounted

@abstract class ActionHandler extends RefCounted: pass # keep this in case we want to DI stuff into Actions later...
@abstract class Conf extends RefCounted: pass # only needed to have nice autocomplete/type check in trigger conf

class ActionHandlerManager extends RefCounted:
	var damage := DamageAction.new()

	func handle(action: Conf, item: Items.Item) -> Array[Events.GameEvent]:
		if action is DamageAction.Conf:
			return damage.handle(action, item)
		else:
			return []
