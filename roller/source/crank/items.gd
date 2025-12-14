class_name Items extends RefCounted

static var DEMON = ItemStaticData.new(
	ItemType.DEVIL, 
	"Lil Demon", 
	[Trigger.new(
		[Conditions.ChanceConditionConf.new()],
		[DamageAction.Conf.new()]
	)], 
	ItemBaseStats.new())

class ItemFactory extends RefCounted:
	var conditions_eval: Conditions.EvaluationDelegator
	var action_handler: Actions.ActionHandlerManager

	func _init():
		conditions_eval = Conditions.EvaluationDelegator.new()
		action_handler = Actions.ActionHandlerManager.new()

	func new_item(conf: ItemStaticData) -> Item:
		return Item.new(conf, conditions_eval, action_handler)

class Item extends RefCounted:
	var def: ItemStaticData
	var triggers: Array[TriggerEvaluator] = []
	var mods: Array[ItemModifier]

	func _init(def, condition_evaluator_manager: Conditions.EvaluationDelegator, action_handler_manager: Actions.ActionHandlerManager):
		self.def = def
		for trigger in def.triggers:
			triggers.append(TriggerEvaluator.new(trigger, condition_evaluator_manager, action_handler_manager))

	func evaluate_triggers() -> Array[Events.GameEvent]:
		var all_events: Array[Events.GameEvent] = []
		for trigger_evaluator in triggers:
			all_events.append_array(trigger_evaluator.evaluate(self))
		return all_events

	func compute_final_stats(base: ItemBaseStats, mods: Array[ItemModifier]) -> ItemBaseStats:
		var copy := base.duplicate(true)
		var multiplicative_mods = Utils.filter(mods, func(m): return m.is_multiplicative)
		var property_to_mult_map := {}
		for mod: ItemModifier in multiplicative_mods:
			property_to_mult_map[mod.property] = (
				Utils.default_if_absent(property_to_mult_map, mod.property, 1.0) + mod.amount)
		for property in property_to_mult_map:
			copy.set(property, copy.get(property) * property_to_mult_map[property])
		var additive_mods = Utils.filter(mods, func(m): return not m.is_multiplicative)
		for mod: ItemModifier in additive_mods:
			copy.set(mod.property, copy.get(mod.property) + mod.amount)
		return ItemBaseStats.new(
			int(copy.damage),
			clampf(copy.chance, 0.0, 1.0),
			clampi(int(copy.cooldown), 0, 1000))

class TriggerEvaluator extends RefCounted:
	var def: Trigger
	var last_triggered_turn: int = -1
	var condition_evaluator_manager: Conditions.EvaluationDelegator
	var action_handler_manager: Actions.ActionHandlerManager

	func _init(def: Trigger, condition_evaluator_manager: Conditions.EvaluationDelegator, action_handler_manager: Actions.ActionHandlerManager):
		self.def = def
		self.condition_evaluator_manager = condition_evaluator_manager
		self.action_handler_manager = action_handler_manager

	func evaluate(item: Item) -> Array[Events.GameEvent]:
		var should_trigger = true
		for condition in def.conditions:
			should_trigger = should_trigger and condition_evaluator_manager.evaluate(condition, item)
		if should_trigger:
			var all_events: Array[Events.GameEvent] = []
			for action in def.actions:
				all_events.append_array(action_handler_manager.handle(action, item))
			return all_events
		else:
			return [] as Array[Events.GameEvent]

class ItemStaticData extends RefCounted:
	var type: ItemType 
	var name: String 
	var triggers: Array[Trigger]
	var base_stats: ItemBaseStats

	func _init(type: ItemType, name: String, triggers: Array[Trigger], base_stats: ItemBaseStats):
		self.type = type
		self.name = name
		self.triggers = triggers
		self.base_stats = base_stats

class ItemBaseStats extends Resource:
	@export var damage: int = 100
	@export var chance: float = 0.5
	@export var cooldown: int = 0

	func _init(damage: int = 100, chance: float = 0.5, cooldown: int = 0):
		self.damage = damage
		self.chance = chance
		self.cooldown = cooldown

class ItemModifier extends RefCounted:
	var property: String
	var amount: float
	var is_multiplicative: bool # else additive
	var permanence: ItemModPermanence

	func _init(property: String, amount: float, is_multiplicative: bool = false, permanence: ItemModPermanence = ItemModPermanence.TURN):
		self.property = property
		self.amount = amount
		self.is_multiplicative = is_multiplicative
		self.permanence = permanence

enum ItemModPermanence {
	TURN,
	ACTIVE,
	PERMANENT
}

class ItemDynamicParams extends RefCounted:
	pass

class Trigger extends RefCounted:
	var conditions: Array[Conditions.ConditionConf]
	var actions: Array[Actions.Conf]

	func _init(conditions: Array[Conditions.ConditionConf], actions: Array[Actions.Conf]):
		self.conditions = conditions
		self.actions = actions

enum ItemType {
	EMPTY,
	DEVIL,
	PRIEST
}
