extends Node2D

const GAME_BOARD_SCENE: PackedScene = preload("res://source/game_board.tscn")

var _round: int = 0
var _score_quota: int
var _current_score: int
var _turns_left: int
var _progress_tween: Tween

func _ready():
	round_setup()
	$Turn.pressed.connect(_on_turn)

func _on_turn():
	if Utils.RNG.randf() > 0.5:
		_current_score += 40
	_on_score_changed(_current_score)
	_turns_left -= 1
	if _turns_left <= 0:
		print("Ended with points: ", _current_score)
		if _current_score >= _score_quota:
			print("Round won. WE'RE DOING IT AGAIN!")
			_round += 1
			round_setup()
		else:
			print("You lost: BYE BYE SUCKER, BOZO, DINGUS!")
			get_tree().quit()
	else:
		stage_setup()

func stage_setup():
	$ProgressDisplay/LivesLabel.text = str(_turns_left) + " Turns To Meet Quota"

func round_setup():
	_turns_left = 5
	_current_score = 0
	_score_quota = 100 * (2 ** _round)
	$ProgressDisplay/ProgressBar.value = 0
	stage_setup()

func _on_score_changed(new_score: int):
	if _progress_tween:
		_progress_tween.kill()
	_progress_tween = create_tween()
	var progress_percent: float = 100.0 * new_score / _score_quota
	_progress_tween.tween_property($ProgressDisplay/ProgressBar, "value", progress_percent, 0.5)
	$ProgressDisplay/Label.text = "%d / %d" % [new_score , _score_quota]

"""
for item in [ordered items]:
	for trigger in item:
		if all conditions match
		do the actions
"""

class Item extends RefCounted:
	var def: ItemStaticData

class ItemStaticData extends RefCounted:
	var type: ItemType
	var name: String
	"""
	trigger[]
		condition(s)
		action(s)
	"""
	var base_damage: int
	var base_chance: float

# Maybe we just have one method outputting the final "compiled" version of this
#class ItemParams extends RefCounted:
	#var damage: int
	#var chance: float

class Trigger extends RefCounted:
	var conditions: Array[Condition]
	var actions: Array[Action]

@abstract class Condition extends RefCounted:
	pass

@abstract class Action extends RefCounted:
	pass
	
	class Damage extends Action:
		pass

enum ItemType {
	EMPTY,
	DEVIL,
	PRIEST
}
