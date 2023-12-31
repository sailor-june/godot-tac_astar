extends Node2D
class_name player_char 
# Variables
var astargrid : AStarGrid2D
var move_speed = 180
var isSelected = false
@onready var grid = get_node("/root/Main/theGrid")

var current_id_path: Array[Vector2i]
var current_path_index=0

#stats go here i guess? maybe i should make a class idk
var char_name = "bbgrl"
@onready var AP = 20
var has_moved = false
signal move_completed
	
func _ready() -> void:
	
	#center yourself (-_-)
	position = grid.local_to_map(position)
	position = grid.map_to_local(position)
	
	
	
func _physics_process(delta):
	if current_id_path.is_empty():
		#no active path.
		return
	var target_position = grid.map_to_local(current_id_path.front())
	position = position.move_toward(target_position, move_speed*get_process_delta_time())
	if position ==  target_position:
		current_id_path.pop_front()
		if current_id_path.is_empty():
			move_completed.emit()

func move_to(target: Vector2) -> void:
	var id_path = astargrid.get_id_path(grid.local_to_map(position), target).slice(1)
	if current_id_path.is_empty():
		current_id_path = id_path
	
		has_moved = true



func set_selected(value: bool) -> void:
	if not has_moved:
		isSelected = value	
		print("Selected:", name,  isSelected)
	else: 
		print ("character has already moved once this turn ")
	
	

