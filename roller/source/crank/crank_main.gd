extends Node2D

# Import the separate modules
const Items = preload("items.gd")
const Conditions = preload("conditions/conditions.gd")
const Actions = preload("actions/actions.gd")
const Events = preload("events/events.gd")

const GAME_BOARD_SCENE: PackedScene = preload("res://source/game_board.tscn")

var _round: int = 0
var _score_quota: int
var _current_score: int
var _turns_left: int
var _progress_tween: Tween

func _on_turn():
	_turns_left -= 1
	display_message("Turn start. %d remain" % _turns_left)
	_activate_items()
	display_progress(_current_score)
	if _turns_left <= 0:
		display_message("Ended with points: %d" % _current_score)
		if _current_score >= _score_quota:
			display_message("Round won. WE'RE DOING IT AGAIN!")
			_round += 1
			round_setup()
		else:
			display_message("You lost: BYE BYE SUCKER, BOZO, DINGUS!")
			$Turn.disabled = true
			$GameOverAudioPlayer.play()
			$GameOverAudioPlayer.finished.connect(func (): get_tree().quit())
	display_turns()

func display_turns():
	$ProgressDisplay/LivesLabel.text = str(_turns_left) + " Turns To Meet Quota"

func round_setup():
	_turns_left = 20
	_current_score = 0
	_score_quota = 50 * (2 ** _round)
	$ProgressDisplay/ProgressBar.value = 0
	display_turns()
	display_progress(_current_score)

func display_progress(new_score: int):
	if _progress_tween:
		_progress_tween.kill()
	_progress_tween = create_tween()
	var progress_percent: float = 100.0 * new_score / _score_quota
	_progress_tween.tween_property($ProgressDisplay/ProgressBar, "value", progress_percent, 0.5)
	$ProgressDisplay/Label.text = "%d / %d" % [new_score , _score_quota]

var msg_counter: int = 0
func display_message(text: String):
	var label := Label.new()
	msg_counter += 1
	label.text = "%s: %s" % [msg_counter, text]
	label.set("theme_override_colors/font_color", Color.BLACK)
	label.set("theme_override_font_sizes/font_size", 12)
	$TextureRect2/ScrollContainer/VBoxContainer.add_child(label)
	$TextureRect2/ScrollContainer/VBoxContainer.move_child(label, 0)

var item_factory := Items.ItemFactory.new()
var event_handler_manager: Events.EventHandlerManager
var items: Array[Items.Item]

func _ready():
	event_handler_manager = Events.EventHandlerManager.new(self)
	items = [item_factory.new_item(Items.DEMON)]
	round_setup()
	$Turn.pressed.connect(_on_turn)

func _activate_items():
	var all_events: Array[Events.Event] = []
	for item in items:
		all_events.append_array(item.evaluate_triggers())
	for event in all_events:
		event_handler_manager.handle(event)
