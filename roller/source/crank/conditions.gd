class_name Conditions extends RefCounted

@abstract class ConditionEvaluator extends RefCounted:
	@abstract func evaluate(condition: ConditionConf, item: Items.Item) -> bool

@abstract class ConditionConf extends RefCounted:
	pass

class ChanceConditionConf extends ConditionConf:
	pass

class ChanceConditionEvaluator extends ConditionEvaluator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()

	func evaluate(condition: ConditionConf, item: Items.Item) -> bool:
		var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
		return rng.randf() < final_stats.chance

class EvaluationDelegator extends RefCounted:
	var chance_evaluator := ChanceConditionEvaluator.new()

	func evaluate(condition: ConditionConf, item: Items.Item) -> bool:
		if condition is ChanceConditionConf:
			return chance_evaluator.evaluate(condition, item)
		else:
			return false
