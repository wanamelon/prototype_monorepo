class_name AddStamina extends ItemSystem.Item

var _added_stamina := false

func activate(state: MatchState):
	if not _added_stamina:
		# TODO: do as status effect
		for item in state.items:
			if item is Roller:
				item._stamina_seconds += 10
				item._max_stamina += 10
		_added_stamina = true
