class_name Utils

static var RNG := RandomNumberGenerator.new()

static func filter(list: Array, predicate: Callable, retain_matching: bool = true):
	var matches = []
	var not_matches = []
	for element in list:
		(matches if predicate.call(element) else not_matches).append(element)
	return matches if retain_matching else not_matches

static func get_only_element_of_list(list: Array):
	assert(list.size() == 1, "Cannot get only element of list with size != 1")
	return list[0]

static func default_if_absent(dict: Dictionary, key, default_value):
	return compute_if_absent(dict, key, func(__): return default_value)

static func compute_if_absent(dict: Dictionary, key, compute_func):
	if not key in dict:
		dict[key] = compute_func.call(key)
	return dict[key]

static func default_dict_if_absent(dict: Dictionary, key):
	if not key in dict:
		dict[key] = {}
	var existing_dictionary_for_key = dict[key]
	assert(
		existing_dictionary_for_key is Dictionary, 
		"Expected dictionary value %s for key %s to be of type Dictionary" % [
			existing_dictionary_for_key, key])
	return existing_dictionary_for_key

# not type safe
static func duplicate_array(original_array: Array) -> Array:
	var duplicated_items: Array = []
	for original_item: Variant in original_array:
		duplicated_items.append(original_item.duplicate())
	return duplicated_items

# not type safe. keys must be primitives
static func duplicate_dict(original_dict: Dictionary) -> Dictionary:
	var duplicated_dict: Dictionary = {}
	for original_key: Variant in original_dict:
		var original_item: Variant = original_dict[original_key]
		var duplicated_item = original_item.duplicate()
		duplicated_dict[original_key] = duplicated_item
	return duplicated_dict
