extends Node2D
# Variables
var astargrid : AStarGrid2D
var move_speed = 250
var isSelected = false
@onready var grid = get_node("/root/Main/theGrid")

var current_id_path: Array[Vector2i]
var current_path_index=0

#stats go here i guess? maybe i should make a class idk
var char_name = "bbgrl"
@onready var AP = 20

func _ready() -> void:
	
	#center yourself (-_-)
	position = grid.local_to_map(position)
	position = grid.map_to_local(position)
	
	
	
func _physics_process(delta):
	if current_id_path.is_empty():
		#no active path.
		return
	var target_position = grid.map_to_local(current_id_path.front())
	position = position.move_toward(target_position,move_speed*get_process_delta_time())
	await get_tree().create_timer(0.3).timeout
	if position ==  target_position:
		current_id_path.pop_front()

func move_to(target: Vector2) -> void:
	var id_path = astargrid.get_id_path(grid.local_to_map(position), target).slice(1)
	if current_id_path.is_empty():
		current_id_path = id_path


#i feel like this should be a signal but idk how they work really
func set_selected(value: bool) -> void:
	isSelected = value	
	print("Selected:", name,  isSelected)

	
	

