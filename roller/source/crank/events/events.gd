class_name Events extends RefCounted

@abstract class Handler extends RefCounted: pass
@abstract class Event extends RefCounted: pass

class EventHandlerManager extends RefCounted:
	var damage := DamageEvent.Handler.new()

	func _init(game_instance: Node2D = null):
		damage.game_instance = game_instance

	func handle(event: Event):
		if event is DamageEvent:
			damage.handle(event)
		else:
			assert(false, "Warning: No handler registered for event type: %s" % event)
