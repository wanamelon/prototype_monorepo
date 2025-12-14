class_name Events extends RefCounted

@abstract class GameEvent extends RefCounted:
	pass

@abstract class EventHandler extends RefCounted:
	@abstract func handle(event: GameEvent)

class DamageEvent extends GameEvent:
	var source_item: Items.Item
	var amount: int
	var target_type: String

	func _init(source_item: Items.Item, amount: int, target_type: String = "enemy"):
		self.source_item = source_item
		self.amount = amount
		self.target_type = target_type

class DamageEventHandler extends EventHandler:
	var game_instance: Node2D

	func _init(game_instance: Node2D = null):
		self.game_instance = game_instance

	func handle(event: GameEvent):
		if event is DamageEvent:
			var damage_event = event as DamageEvent
			if game_instance:
				game_instance._current_score += damage_event.amount
				game_instance.display_message("%s did %d damage" % [damage_event.source_item.def.name, damage_event.amount])
				game_instance.display_progress(game_instance._current_score)
			else:
				print("Error: DamageEventHandler has no reference to game instance")

class EventHandlerManager extends RefCounted:
	var damage_handler: DamageEventHandler

	func _init(game_instance: Node2D = null):
		damage_handler = DamageEventHandler.new(game_instance)

	func handle(event: GameEvent):
		if event is DamageEvent:
			damage_handler.handle(event)
		else:
			print("Warning: No handler registered for event type: %s" % event.__class__)
