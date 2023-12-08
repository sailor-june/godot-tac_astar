extends Node2D
class_name PlayerCommander

func _process_turn():
	$UI.visible = true
	$Cursor.visible = true
	await $UI/EndTurn.pressed
	$UI.visible = false
	$Cursor.visible = false
