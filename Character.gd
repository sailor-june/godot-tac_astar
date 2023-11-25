extends Node2D

# Variables
var astargrid = AStar2D
var move_speed = 250
var isSelected = false
@onready var grid = get_node("/root/Main/theGrid")
var current_id_path: Array[Vector2i]
var current_path_index=0
var movePoint = Vector2i.ZERO

func _ready() -> void:
	
	astargrid = AStarGrid2D.new()
	astargrid.region =  grid.get_used_rect()
	astargrid.cell_size = Vector2i(64,64)
	
	#manhattan distance, no diagonals
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	
	
	position = grid.map_to_local(position)
	movePoint = position
	
	
func _physics_process(delta):
	
	if current_id_path.is_empty():
		return
	
	var target_position = grid.map_to_local(current_id_path.front())

	position = position.move_toward(target_position,move_speed*get_process_delta_time())
	if position ==  target_position:
		current_id_path.pop_front()

func move_to(target: Vector2) -> void:
	
	var id_path = astargrid.get_id_path(grid.local_to_map(position), target).slice(1)
	print(target)
	print("ID PATH ", id_path)
	
		
	if current_id_path.is_empty():
		print('adding path')
		current_id_path = id_path

func set_selected(value: bool) -> void:
	isSelected = value
	print("Selected:", name,  isSelected)

#func follow_path(current_path, current_path_index):
#
#	if current_path_index > current_path.size()+1:
#		current_path=null
#		return
#	current_path_index+=1
#	movePoint = grid.map_to_local(current_path[current_path_index])
#	print(movePoint)
#	print(current_path_index)
#	print(current_path)
#	return
