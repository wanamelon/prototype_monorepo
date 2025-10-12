extends Control

const PLACED_ITEM_SCENE: PackedScene = preload("res://source/placed_item.tscn")

const initial_placements: Array[Variant] = [
	[ENUM.Items.ITEM_1, Vector2(64, 64 * 2), PI / 2],
	[ENUM.Items.ITEM_1, Vector2(64 * 8, 64), PI],
	[ENUM.Items.ITEM_1, Vector2(64 * 4, 64), PI],
	[ENUM.Items.ITEM_2, Vector2(64 * 5, 64 * 3), 0]
]

func _ready():
	for placement in initial_placements:
		var placed_item = PlacedItem.new(placement[0], self, self._can_drop_data, self._drop_data)
		placed_item.position = placement[1]
		placed_item.rotation = placement[2]
		add_child(placed_item)

func _can_drop_data(at_position, data):
	return true

func _drop_data(at_position, data):
	var item_data := data as TestPreview
	var placed_item: PlacedItem = PlacedItem.new(item_data.get_item_data().item_type, self, self._can_drop_data, self._drop_data)
	placed_item.rotation = data.rotation
	placed_item.position = at_position
	add_child(placed_item)
