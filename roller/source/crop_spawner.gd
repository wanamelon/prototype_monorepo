class_name CropSpawner extends ItemSystem.Item

const CROP_SCENE: PackedScene = preload("res://source/crop.tscn")
var _random := RandomNumberGenerator.new()

func activate(state: MatchState):
	var events: Array[ItemEvent] = []
	if state.tick == 0:
		for i in range(5): # TODO: configurable?
			var factory = func ():
				var crop = CROP_SCENE.instantiate()
				crop.level = _random.randi_range(1, 12)
				return crop
			events.append(ItemSystem.SpawnEvent.new(factory, ItemSystem.AnyFreeCell.new(), 1.0))
	return events
