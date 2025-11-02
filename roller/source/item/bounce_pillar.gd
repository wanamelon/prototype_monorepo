class_name BouncePillar extends ItemSystem.Item

var hit_points: int = 5

static func instance() -> BouncePillar:
	return load("res://source/item/bounce_pillar.tscn").instantiate()

func activate(state: MatchState):
	if ($StaticBody2D/CollisionShape2D.disabled
		and _item_root.is_safe_to_place($StaticBody2D/CollisionShape2D.shape, global_position)):
		$StaticBody2D/CollisionShape2D.disabled = false
	for overlap: ItemSystem.FreshOverlapEvent in Utils.filter(state.last_tick_events, func (e): return e is ItemSystem.FreshOverlapEvent):
		if overlap.first.has_all_tags(Tag.ROLLER) and overlap.second.matches(self):
			hit_points -= 1
			if hit_points <= 0:
				_add_event(ItemSystem.DespawnEvent.new(self, overlap.first))
				break
