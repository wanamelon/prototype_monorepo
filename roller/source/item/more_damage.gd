class_name MoreDamage extends ItemSystem.Item

func activate(state: MatchState):
	for item in state.items:
		if item is Roller:
			# TODO: Less boilerplate?
			var buff_damage: Callable = func(s: StatusEffect, i: ItemSystem.Item):
				for param: ItemParam in Utils.filter(i.params(), func(p:ItemParam): p.tags.has_all_tags(Tag.P_DAMAGE)):
					param.current.value += int(s.intensity)
			_add_event(ItemSystem.AddStatusEffect.new(
				ItemSystem.StatusEffect.new(ItemSystem.StatusEffectId.DAMAGE_BUFF, 5, 0, buff_damage), item))
