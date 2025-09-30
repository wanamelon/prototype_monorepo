extends Node2D

func _ready():
	$Fish.fish_placement_attempted.connect($GameBoardGrid.handle_fish_placement)
