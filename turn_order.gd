extends Node2D
class_name TurnOrder

signal turn_ended(agent: Node2D)
signal round_ended()

var execute_next_frame: bool = true
var round_count = 1

func _ready():
	pass

func _process(delta):
	if execute_next_frame:
		execute_round_async()
		execute_next_frame = false
	
func execute_round_async():
	print("Starting round " + str(round_count))
	for c in get_children():
		if not c.has_method('_process_turn'):
			continue
		await c._process_turn()
		turn_ended.emit(c)
	round_ended.emit()
	round_count += 1
	execute_next_frame = true
