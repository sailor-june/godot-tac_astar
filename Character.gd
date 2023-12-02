extends Node2D

# Variables
var astargrid = AStar2D
var move_speed = 250
var isSelected = false
@onready var grid = get_node("/root/Main/theGrid")
var current_id_path: Array[Vector2i]
var current_path_index=0

#stats go here i guess? maybe i should make a class idk
@onready var AP = 4

func _ready() -> void:
	
	#instantiate Astargrid
	astargrid = AStarGrid2D.new()
	astargrid.region =  grid.get_used_rect()
	astargrid.cell_size = Vector2i(64,64)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	
	
	for x in grid.get_used_rect().size.x:
		for y in grid.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + grid.get_used_rect().position.x,
				y +grid.get_used_rect().position.y
			)
			
			var tile_data = grid.get_cell_tile_data(0, tile_position)
			var terrain_cost = tile_data.get_custom_data("Cost")
			if terrain_cost != null:
				astargrid.set_point_weight_scale(tile_position, terrain_cost)
			if tile_data == null or tile_data.get_custom_data("walkable")==false:
				astargrid.set_point_solid(tile_position)
		
	
	#center yourself (-_-)
	position = grid.local_to_map(position)
	position = grid.map_to_local(position)
	
	
	
func _physics_process(delta):
	if current_id_path.is_empty():
		#no active path.
		return
	
	var target_position = grid.map_to_local(current_id_path.front())
	position = position.move_toward(target_position,move_speed*get_process_delta_time())
	if position ==  target_position:
		current_id_path.pop_front()

func move_to(target: Vector2) -> void:
	
	var id_path = astargrid.get_id_path(grid.local_to_map(position), target).slice(1)
	print("ID PATH :")
	for step in id_path:
		print("step: ", step, "cost: ", astargrid.get_point_weight_scale(step))
		
	if current_id_path.is_empty():
	
		current_id_path = id_path


#i feel like this should be a signal but idk how they work really
func set_selected(value: bool) -> void:
	isSelected = value	
	print("Selected:", name,  isSelected)

	
	

