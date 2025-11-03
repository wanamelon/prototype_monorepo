class_name CropSpawner extends ItemSystem.Item

var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	if state.tick == 0:
		for i in range(10): # TODO: configurable?
			_add_event(ItemSystem.SpawnEvent.new(
				func (): return Crop.instance(2, 1), ItemSystem.AnyFreeCell.new()))
