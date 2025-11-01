class_name CropSpawner extends ItemSystem.Item

var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	if state.tick == 0:
		for i in range(20): # TODO: configurable?
			var factory = func ():
				var crop := Crop.instance()
				crop.level = _random.randi_range(1, 1)
				return crop
			_add_event(ItemSystem.SpawnEvent.new(factory, ItemSystem.AnyFreeCell.new(), 1.0))
