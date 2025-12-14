class_name DamageEvent extends Events.Event

var source_item: Items.Item
var amount: int
var target_type: String

func _init(source_item: Items.Item, amount: int, target_type: String = "enemy"):
	self.source_item = source_item
	self.amount = amount
	self.target_type = target_type

class Handler extends Events.Handler:
	var game_instance: Node2D

	func handle(event: DamageEvent):
		var damage_event = event
		game_instance._current_score += damage_event.amount
		game_instance.display_message("%s did %d damage" % [damage_event.source_item.def.name, damage_event.amount])
		game_instance.display_progress(game_instance._current_score)
