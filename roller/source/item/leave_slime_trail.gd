class_name LeaveSlimeTrail extends ItemSystem.Item

var _roller_to_last_slimed_state := {}

func activate(state: MatchState):
	for item in state.items:
		if item is Roller:
			var last_slimed_state = Utils.compute_if_absent(
				_roller_to_last_slimed_state, item, func (__): return {"position": item.position, "distance_since_last_slimed": 0})
			last_slimed_state.distance_since_last_slimed += (item.position - last_slimed_state.position).length()
			last_slimed_state.position = item.position
			if last_slimed_state.distance_since_last_slimed > 50:
				# TODO: spawn in right locus
				_add_event(ItemSystem.SpawnEvent.new(SlimeTrail.instance, ItemSystem.SpecificPosition.new(item.position), 1.0))
				last_slimed_state.distance_since_last_slimed = 0
