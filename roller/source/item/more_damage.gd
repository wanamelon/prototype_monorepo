class_name MoreDamage extends ItemSystem.Item

func activate(state: MatchState):
	for item in state.items:
		if item is Roller:
			_add_event(ItemSystem.AddStatusEffect.new(
				ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.DAMAGE_BUFF, 1, state.delta * 1.1), item))
