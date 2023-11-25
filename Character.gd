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
			
			if tile_data == null or tile_data.get_custom_data("walkable")==false:
				astargrid.set_point_solid(tile_position)
		
	
	#center yourself (-_-)
	position = grid.map_to_local(position)
	movePoint = position
	
	
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
	print(target)
	print("ID PATH ", id_path)
	
		
	if current_id_path.is_empty():
		print('adding path')
		current_id_path = id_path

func set_selected(value: bool) -> void:
	isSelected = value
	print("Selected:", name,  isSelected)

