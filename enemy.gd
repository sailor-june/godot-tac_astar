extends Node2D
@onready var grid = get_node("/root/Main/theGrid")
@onready var astargrid : AStarGrid2D
var move_speed = 250
var moving = false
var current_id_path = []
var current_target : Vector2i




## Called when the node enters the scene tree for the first time.
func _ready():
	position = grid.local_to_map(position)
	position = grid.map_to_local(position)

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	if current_id_path.is_empty() or moving == false:
		moving = false
		return
	var target_position = grid.map_to_local(current_id_path.front())
	position = position.move_toward(target_position,move_speed*get_process_delta_time())
	if position ==  target_position:
		current_id_path.pop_front()
		print(current_target)
		print(moving)
