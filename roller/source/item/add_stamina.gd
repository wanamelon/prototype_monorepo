class_name AddStamina extends ItemSystem.Item

var _items_added_stamina_for = []

func activate(state: MatchState):
	for item in state.items:
		if item is Roller and not item in _items_added_stamina_for:
			_add_event(ItemSystem.AddStatusEffect.new(
				ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.STAMINA_BUFF, 2, 1e9), item))
			_items_added_stamina_for.append(item)
