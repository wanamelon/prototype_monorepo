class_name BouncePillar extends ItemSystem.Item

var hit_points: int = 5

static func instance() -> BouncePillar:
	return load("res://source/bounce_pillar.tscn").instantiate()

func activate(state: MatchState):
	if ($StaticBody2D/CollisionShape2D.disabled
		and _item_root.is_safe_to_place($StaticBody2D/CollisionShape2D.shape, global_position)):
		$StaticBody2D/CollisionShape2D.disabled = false
	for event in state.last_tick_events:
		if event is ItemSystem.FreshOverlapEvent:
			var overlap := event as ItemSystem.FreshOverlapEvent
			if overlap.first is Roller and overlap.second == self:
				hit_points -= 1
				if hit_points <= 0:
					_add_event(ItemSystem.DespawnEvent.new(self, overlap.first))
					break
