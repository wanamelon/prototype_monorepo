class_name AddStamina extends ItemSystem.Item

var _items_added_stamina_for = []

func activate(state: MatchState):
	for roller: Roller in Utils.filter(state.items, func(i): return i is Roller and not i in _items_added_stamina_for):
		_add_event(ItemSystem.AddStatusEffect.new(
			ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.STAMINA_BUFF, 2, 1e9), roller))
		_items_added_stamina_for.append(roller)
