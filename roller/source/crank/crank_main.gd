extends Node2D

const GAME_BOARD_SCENE: PackedScene = preload("res://source/game_board.tscn")

var _round: int = 0
var _score_quota: int
var _current_score: int
var _turns_left: int
var _progress_tween: Tween

func _on_turn():
	_turns_left -= 1
	display_message("Turn start. %d remain" % _turns_left)
	_activate_items()
	display_progress(_current_score)
	if _turns_left <= 0:
		display_message("Ended with points: %d" % _current_score)
		if _current_score >= _score_quota:
			display_message("Round won. WE'RE DOING IT AGAIN!")
			_round += 1
			round_setup()
		else:
			display_message("You lost: BYE BYE SUCKER, BOZO, DINGUS!")
			$Turn.disabled = true
			$GameOverAudioPlayer.play()
			$GameOverAudioPlayer.finished.connect(func (): get_tree().quit())
	display_turns()

func display_turns():
	$ProgressDisplay/LivesLabel.text = str(_turns_left) + " Turns To Meet Quota"

func round_setup():
	_turns_left = 20
	_current_score = 0
	_score_quota = 50 * (2 ** _round)
	$ProgressDisplay/ProgressBar.value = 0
	display_turns()
	display_progress(_current_score)

func display_progress(new_score: int):
	if _progress_tween:
		_progress_tween.kill()
	_progress_tween = create_tween()
	var progress_percent: float = 100.0 * new_score / _score_quota
	_progress_tween.tween_property($ProgressDisplay/ProgressBar, "value", progress_percent, 0.5)
	$ProgressDisplay/Label.text = "%d / %d" % [new_score , _score_quota]

var msg_counter: int = 0
func display_message(text: String):
	var label := Label.new()
	msg_counter += 1
	label.text = "%s: %s" % [msg_counter, text]
	label.set("theme_override_colors/font_color", Color.BLACK)
	label.set("theme_override_font_sizes/font_size", 12)
	$TextureRect2/ScrollContainer/VBoxContainer.add_child(label)
	$TextureRect2/ScrollContainer/VBoxContainer.move_child(label, 0)

var condition_evaluator_manager: ConditionEvaluatorManager
var action_handler_manager: ActionHandlerManager
var items: Array[Item]

static var DEMON = ItemStaticData.new(ItemType.DEVIL, "Lil Demon", [Trigger.new([ChanceCondition.new()], [DamageAction.new()])], ItemBaseStats.new())

func _ready():
	condition_evaluator_manager = ConditionEvaluatorManager.new()
	action_handler_manager = ActionHandlerManager.new()
	items = [Item.new(DEMON, condition_evaluator_manager, action_handler_manager)]
	round_setup()
	$Turn.pressed.connect(_on_turn)

func _activate_items():
	var all_events: Array[GameEvent] = []
	for item in items:
		all_events.append_array(item.evaluate_triggers())
	for event in all_events:
		apply_event(event)

func apply_event(event: GameEvent):
	if event is DamageEvent:
		apply_damage_event(event)

func apply_damage_event(event: DamageEvent):
	_current_score += event.amount
	display_message("%s did %d damage" % [event.source_item.def.name, event.amount])
	display_progress(_current_score)


class Item extends RefCounted:
	var def: ItemStaticData
	var triggers: Array[TriggerEvaluator] = []
	var mods: Array[ItemModifier]

	func _init(def, condition_evaluator_manager: ConditionEvaluatorManager, action_handler_manager: ActionHandlerManager):
		self.def = def
		for trigger in def.triggers:
			triggers.append(TriggerEvaluator.new(trigger, condition_evaluator_manager, action_handler_manager))
	
	func evaluate_triggers() -> Array[GameEvent]:
		var all_events: Array[GameEvent] = []
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
	var condition_evaluator_manager: ConditionEvaluatorManager
	var action_handler_manager: ActionHandlerManager

	func _init(def: Trigger, condition_evaluator_manager: ConditionEvaluatorManager, action_handler_manager: ActionHandlerManager):
		self.def = def
		self.condition_evaluator_manager = condition_evaluator_manager
		self.action_handler_manager = action_handler_manager

	func evaluate(item: Item) -> Array[GameEvent]:
		var should_trigger = true
		for condition in def.conditions:
			should_trigger = should_trigger and condition_evaluator_manager.evaluate(condition, item)
		if should_trigger:
			var all_events: Array[GameEvent] = []
			for action in def.actions:
				all_events.append_array(action_handler_manager.handle(action, item))
			return all_events
		else:
			return [] as Array[GameEvent]

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

# We can have mods like "+30 damage until item returned to pool", "+0.5 chance mult"
# This should track the latest state of things!
class ItemDynamicParams extends RefCounted:
	pass

class Trigger extends RefCounted:
	var conditions: Array[Condition]
	var actions: Array[Action]

	func _init(conditions: Array[Condition], actions: Array[Action]):
		self.conditions = conditions
		self.actions = actions

class ChanceConditionEvaluator extends ConditionEvaluator:
	func evaluate(condition: Condition, item: Item) -> bool:
		var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
		return Utils.RNG.randf() < final_stats.chance

class ConditionEvaluatorManager extends RefCounted:
	var chance_evaluator: ChanceConditionEvaluator

	func _init():
		chance_evaluator = ChanceConditionEvaluator.new()

	func evaluate(condition: Condition, item: Item) -> bool:
		if condition is ChanceCondition:
			return chance_evaluator.evaluate(condition, item)
		else:
			return false

@abstract class ConditionEvaluator extends RefCounted:
	@abstract func evaluate(condition: Condition, item: Item) -> bool

class ChanceCondition extends Condition:
	pass

@abstract class Condition extends RefCounted:
	pass

@abstract class Action extends RefCounted:
	pass
	

class DamageEvent extends GameEvent:
	var source_item: Item
	var amount: int
	var target_type: String  # e.g. "enemy", "player", etc.

	func _init(source_item: Item, amount: int, target_type: String = "enemy"):
		self.source_item = source_item
		self.amount = amount
		self.target_type = target_type

class ActionHandlerManager extends RefCounted:
	var damage_handler: DamageActionHandler

	func _init():
		damage_handler = DamageActionHandler.new()

	func handle(action: Action, item: Item) -> Array[GameEvent]:
		if action is DamageAction:
			return damage_handler.handle(action, item)
		else:
			# For unregistered actions, return empty array
			return []

@abstract class ActionHandler extends RefCounted:
	@abstract func handle(action: Action, item: Item) -> Array[GameEvent]

class DamageActionHandler extends ActionHandler:
	func handle(action: Action, item: Item) -> Array[GameEvent]:
		var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
		var damage_event = DamageEvent.new(item, final_stats.damage)
		return [damage_event]

@abstract class GameEvent extends RefCounted:
	# Abstract base class for all game events
	pass

class DamageAction extends Action:
	pass

enum ItemType {
	EMPTY,
	DEVIL,
	PRIEST
}
