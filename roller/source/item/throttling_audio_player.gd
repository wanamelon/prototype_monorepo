class_name ThrottlingAudioPlayer extends Node2D

static func instance() -> ThrottlingAudioPlayer:
	return load("res://source/item/throttling_audio_player.tscn").instantiate()

func play_add_size_buff():
	$AddSizeBuff.play()
