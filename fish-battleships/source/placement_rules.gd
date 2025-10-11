class_name PlacementRules extends Resource

enum ItemType {
	SUBSTRATE,
	ORGAN
}

@export var required_overlapping_item_types: Array[ItemType]
@export var disallowed_overlapping_item_types: Array[ItemType]
@export var required_neighboring_item_types: Array[ItemType]
@export var disallowed_neighboring_item_types: Array[ItemType]

func _init(
	required_overlapping_item_types: Array[ItemType] = [],
	disallowed_overlapping_item_types: Array[ItemType] = [],
	required_neighboring_item_types: Array[ItemType] = [],
	disallowed_neighboring_item_types: Array[ItemType] = []
):
	self.required_overlapping_item_types = required_overlapping_item_types 
	self.disallowed_overlapping_item_types = disallowed_overlapping_item_types 
	self.required_neighboring_item_types = required_neighboring_item_types 
	self.disallowed_neighboring_item_types = disallowed_neighboring_item_types 
