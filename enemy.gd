extends Node2D
@onready var grid = get_node("/root/Main/theGrid")
var current_id_path: Array[Vector2i]
var current_path_index=0
var astargrid= AStarGrid2D

@onready var AP = 10
@onready var move_speed = 5
## Called when the node enters the scene tree for the first time.
func _ready():
	position = grid.local_to_map(position)
	position = grid.map_to_local(position)

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_id_path.is_empty():
		#no active path.
		return
	var target_position = grid.map_to_local(current_id_path.front())
	position = position.move_toward(target_position,move_speed*get_process_delta_time())
	await get_tree().create_timer(0.3).timeout
	if position ==  target_position:
		current_id_path.pop_front()
