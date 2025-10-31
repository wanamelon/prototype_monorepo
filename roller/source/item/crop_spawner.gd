class_name CropSpawner extends ItemSystem.Item

var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	if state.tick == 0:
		for i in range(10): # TODO: configurable?
			var factory = func ():
				var crop := Crop.instance()
				crop.level = _random.randi_range(1, 3)
				return crop
			events.append(ItemSystem.SpawnEvent.new(factory, ItemSystem.AnyFreeCell.new(), 1.0))
	return events
