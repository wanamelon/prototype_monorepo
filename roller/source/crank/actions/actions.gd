class_name Actions extends RefCounted

@abstract class Handler extends RefCounted: pass # keep this in case we want to DI stuff into Actions later...
@abstract class Conf extends RefCounted: pass # only needed to have nice autocomplete/type check in trigger conf

class ActionHandlerManager extends RefCounted:
	var damage := DamageAction.Handler.new()

	func handle(action: Conf, item: Items.Item) -> Array[Events.Event]:
		if action is DamageAction:
			return damage.handle(action, item)
		else:
			return []
