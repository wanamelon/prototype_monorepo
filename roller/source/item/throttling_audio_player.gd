class_name ThrottlingAudioPlayer extends Node2D

static func instance() -> ThrottlingAudioPlayer:
	return load("res://source/item/throttling_audio_player.tscn").instantiate()

func play_add_size_buff():
	$AddSizeBuff.play()

func play_add_speed_buff():
	$AddSpeedBuff.play()

func play_gain_points(points: int):
	$GainPoints.pitch_scale = 1.2 - min(0.9, 0.9 * (log(points) / log(1e6)))
	$GainPoints.play()

func play_crop_level_up():
	$CropLevelUp.play()

func play_crop_level_down():
	$CropLevelDown.play()

func play_spawn_mini_ball():
	$SpawnMiniBall.play()

func play_bounce():
	$BounceAudioPlayer.play()
