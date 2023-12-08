extends Node2D

func _on_turn_started(agent):
	$TurnLabel.text = "Turn: " + agent.name
	
func _on_turn_ended(agent):
	print('Turn ended: ' + agent.name)

func _on_round_ended():
	print('Round ended')

