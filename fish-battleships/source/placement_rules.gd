class_name PlacementRules extends Resource

@export var required_overlapping_item_types: Array[ENUM.Layer]
@export var disallowed_overlapping_item_types: Array[ENUM.Layer]
@export var required_neighboring_item_types: Array[ENUM.Layer]
@export var disallowed_neighboring_item_types: Array[ENUM.Layer]

func _init(
	required_overlapping_item_types: Array[ENUM.Layer] = [],
	disallowed_overlapping_item_types: Array[ENUM.Layer] = [],
	required_neighboring_item_types: Array[ENUM.Layer] = [],
	disallowed_neighboring_item_types: Array[ENUM.Layer] = []
):
	self.required_overlapping_item_types = required_overlapping_item_types 
	self.disallowed_overlapping_item_types = disallowed_overlapping_item_types 
	self.required_neighboring_item_types = required_neighboring_item_types 
	self.disallowed_neighboring_item_types = disallowed_neighboring_item_types 
