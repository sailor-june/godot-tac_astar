extends Node2D
@onready var grid = get_node("/root/Main/theGrid")
var astargrid : AStarGrid2D
## Called when the node enters the scene tree for the first time.
func _ready():
	position = grid.local_to_map(position)
	position = grid.map_to_local(position)

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
