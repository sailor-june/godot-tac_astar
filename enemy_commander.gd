extends Node2D
class_name EnemyCommander

var main
var enemy

func _ready():
	main = get_node("/root/Main") # Access the grandparent node using the absolute path
	enemy = main.get_node("enemy") if main else null # Access the enemy node within Main if main exists

   

func get_cells_in_range():
	if main && enemy:
		return main.get_cells_in_range(enemy)  # Call the function in the grandparent
	else:
		print("Main or enemy node not found")
		return null

func _process_turn():
	if main && enemy:
		print(get_cells_in_range() )# Call get_cells_in_range from _process_turn
	else:
		print("Main or enemy node not found")

# Add a function to be called externally
