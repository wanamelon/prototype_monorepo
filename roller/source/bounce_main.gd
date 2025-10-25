extends Node2D

const GAME_BOARD_SCENE: PackedScene = preload("res://source/game_board.tscn")

var round: int = 0
var points_quota: int = 20
var point_progress_bar_tween: Tween
var _player_ball: PlayerBall
var _lives_remaining: int = 3
@export var items: Array[ItemDef]

func _ready():
	round_setup()

func _on_player_finish(points: int):
	_lives_remaining -= 1
	if _lives_remaining <= 0:
		print("Ended with points: ", _current_score)
		if _current_score >= points_quota:
			print("Round won. WE'RE DOING IT AGAIN!")
			round += 1
			generate_choices()
		else:
			print("You lost: BYE BYE SUCKER, BOZO, DINGUS!")
			get_tree().quit()
	else:
		stage_setup()

func stage_setup():
	$GameBoard.generate_grid_items(round)
	_player_ball = $GameBoard.spawn_ball(items)
	_player_ball.finished.connect(_on_player_finish)
	_player_ball.gained_points.connect(_on_gain_points)

func round_setup():
	_lives_remaining = 3
	_current_score = 0
	points_quota = 20 * (2 ** round)
	$ProgressDisplay/ProgressBar.value = 0
	stage_setup()

var _current_score: int = 0

const ITEM_BUTTON_SCENE: PackedScene = preload("res://source/item_choice_button.tscn")

func generate_choices():
	$ItemSelect.show()
	for child in $ItemSelect/GridContainer.get_children():
		child.queue_free()
	# Choose random 3 of enum items
	var possible_item_ids = ItemDef.ItemId.keys().duplicate()
	possible_item_ids.shuffle()
	for i in range(3):
		var button: Button = ITEM_BUTTON_SCENE.instantiate()
		button.text = format_enum_name(possible_item_ids[i])
		$ItemSelect/GridContainer.add_child(button)
		button.pressed.connect(func ():
			items.append(ItemDef.new(ItemDef.ItemId[possible_item_ids[i]]))
			$ItemSelect.hide()
			round_setup())

func format_enum_name(enum_name: String) -> String:
	var formatted_name = enum_name.to_lower().replace("_", " ")
	return formatted_name.capitalize()

func _on_gain_points(points: int):
	_current_score += points
	if point_progress_bar_tween:
		point_progress_bar_tween.kill()
	point_progress_bar_tween = create_tween()
	var progress_percent: float = 100.0 * _current_score / points_quota
	point_progress_bar_tween.tween_property($ProgressDisplay/ProgressBar, "value", progress_percent, 0.5)
	$ProgressDisplay/Label.text = "%d / %d" % [_current_score , points_quota]
