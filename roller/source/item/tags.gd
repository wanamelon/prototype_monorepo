class_name Tags extends RefCounted

var tags: Array[String]

func _init(tags: Array[String]):
	self.tags = tags

static func of(...tags: Array) -> Tags:
	return Tags.from(tags)

static func from(untyped_array) -> Tags:
	var new_tags: Array[String] = []
	new_tags.assign(untyped_array)
	return Tags.new(new_tags)

func has_all_tags(...query_tags: Array):
	var query_tags_in_self = Utils.filter(query_tags, func (t): return t in tags)
	return query_tags_in_self.size() == query_tags.size()

func has_any_tags(...query_tags: Array):
	var query_tags_in_self = Utils.filter(query_tags, func (t): return t in tags)
	return not query_tags_in_self.is_empty()
