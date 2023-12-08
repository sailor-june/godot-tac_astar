extends Node2D
class_name PlayerCommander

func _process_turn():
	await get_tree().create_timer(2.0).timeout
