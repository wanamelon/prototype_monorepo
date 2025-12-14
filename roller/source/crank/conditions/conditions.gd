class_name Conditions extends RefCounted

@abstract class Evaluator extends RefCounted: pass
@abstract class Conf extends RefCounted: pass # only needed to have nice autocomplete/type check in trigger conf

class ConditionEvaluatorManager extends RefCounted:
	var chance := ChanceCondition.Evaluator.new()

	func evaluate(condition: Conf, item: Items.Item) -> bool:
		if condition is ChanceCondition:
			return chance.evaluate(condition, item)
		else:
			return false
