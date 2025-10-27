class_name ItemSystem extends Node

var _items: Array[Item] = []
var _player_ball: PlayerBall
var _game_board: GameBoard
var _tick: int = 0

func _init(items: Array[ItemDef], player_ball: PlayerBall, game_board: GameBoard):
	for item_def in items:
		_items.append(_item_for_id(item_def.item_id))
	_player_ball = player_ball
	_game_board = game_board

func add_item(item_id: ItemDef.ItemId):
	_items.append(_item_for_id(item_id))

func _item_for_id(item_id: ItemDef.ItemId) -> Item:
	match item_id:
		ItemDef.ItemId.ADD_STAMINA:
			return AddStaminaItem.new()
		_:
			return AddStaminaItem.new()

func _physics_process(delta):
	for item: Item in _items:
		item.activate(_tick, _player_ball, _game_board)
	_tick += 1

@abstract
class Item extends RefCounted:
	@abstract func activate(tick: int, player: PlayerBall, board: GameBoard) -> Array[ItemEvent]

class AddStaminaItem extends Item:
	var _added_stamina := false
	
	func activate(tick: int, player: PlayerBall, board: GameBoard):
		if not _added_stamina:
			player._stamina_seconds += 2
			player._max_stamina += 2
			_added_stamina = true

@abstract
class ItemEvent extends RefCounted:
	pass

class PlayerOverlapEvent extends ItemEvent:
	pass

class LevelUpEvent extends ItemEvent:
	pass
