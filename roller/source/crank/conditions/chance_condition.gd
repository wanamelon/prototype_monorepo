class_name ChanceCondition extends Conditions.Conf

class Evaluator extends Conditions.Evaluator:
	func evaluate(condition: Conf, item: Items.Item) -> bool:
		var final_stats = item.compute_final_stats(item.def.base_stats, item.mods)
		return Utils.RNG.randf() < final_stats.chance
