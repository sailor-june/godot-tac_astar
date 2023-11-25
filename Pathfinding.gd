extends Node

func _ready() -> void:
	
	
	var astargrid = AStarGrid2D.new()
	astargrid.size = Vector2i(10,6)
	astargrid.cell_size = Vector2i(64,64)
	#manhattan distance, no diagonals
	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.update()
	
	
#
