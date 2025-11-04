class_name ItemParam extends RefCounted

static var IDENTITY: Callable = func(base, curr): return curr.value

static func clamped(min = -2^32, max = 2^32-1) -> Callable:
	return func(base, curr): return clamp(curr.value, min, max)

var base: Prop
var current: Prop
var tags: Tags
var constraint: Callable # func(base, current) -> constrained current value

static func create(base_value, tags: Tags = null, constraint: Callable = IDENTITY) -> ItemParam:
	tags = tags if tags != null else Tags.from([])
	return ItemParam.new(Prop.new(base_value), Prop.new(base_value), tags, constraint)

func _init(base: Prop, current: Prop, tags: Tags, constraint: Callable):
	self.base = base
	self.current = current
	self.tags = tags
	self.constraint = constraint

func constrain():
	current.value = constraint.call(base, current)

func reset():
	current = Prop.new(base.value)

class Prop extends RefCounted:
	var value: float
	
	func int() -> int:
		return int(value)
	func float() -> float:
		return value
	func bool() -> bool:
		return bool(value)
	
	func _init(value):
		self.value = float(value)
	
	
