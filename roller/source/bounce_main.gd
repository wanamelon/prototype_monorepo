extends Node2D

var round: int = 0
var points_quota: int = 20
var point_progress_bar_tween: Tween
var _player_ball: PlayerBall
@export var items: Array[ItemDef]

func _ready():
	round_setup()

func _on_player_finish(points: int):
	print("Ended with points: ", points)
	if points >= points_quota:
		print("Round won. WE'RE DOING IT AGAIN!")
		round += 1
		round_setup()
	else:
		print("You lost: BYE BYE SUCKER, BOZO, DINGUS!")
		get_tree().quit()

func round_setup():
	if round != 0:
		points_quota *= 1.5
	$ProgressDisplay/ProgressBar.value = 0
	$GameBoard.generate_grid_items(round)
	_player_ball = $GameBoard.spawn_ball(items)
	_player_ball.finished.connect(_on_player_finish)
	_player_ball.points_changed.connect(_on_player_points_changed)

func _on_player_points_changed(old, new):
	if point_progress_bar_tween:
		point_progress_bar_tween.kill()
	point_progress_bar_tween = create_tween()
	var progress_percent: float = 100.0 * new / points_quota
	point_progress_bar_tween.tween_property($ProgressDisplay/ProgressBar, "value", progress_percent, 0.5)
	$ProgressDisplay/Label.text = "%d / %d" % [new , points_quota]
