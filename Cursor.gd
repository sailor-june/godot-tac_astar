
extends Node2D
var astargrid = AStarGrid2D
var move_speed = 200
var move_threshold = 0.01
var grid_size = 64
var selected_char = null
@onready var tilemap = get_node("/root/Main/theGrid") #reference to tilemap
var move_point : Vector2 = Vector2.ZERO

func _ready():
	astargrid = AStarGrid2D.new()
	astargrid.region =  tilemap.get_used_rect()
	astargrid.cell_size = Vector2i(64,64)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	
	
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tilemap.get_used_rect().position.x,
				y +tilemap.get_used_rect().position.y
			)
			
			var tile_data = tilemap.get_cell_tile_data(0, tile_position)
			var terrain_cost = tile_data.get_custom_data("Cost")
			if terrain_cost != null:
				astargrid.set_point_weight_scale(tile_position, terrain_cost)
			if tile_data == null or tile_data.get_custom_data("walkable")==false:
				astargrid.set_point_solid(tile_position)
	# Initialize move point at current cursor position
	move_point = position

func _process(_delta):
	# Move cursor towards move point
	position = position.move_toward(move_point, move_speed * get_process_delta_time())
	
	# Check if cursor is close enough to the move point to allow input handling
	if position.distance_to(move_point) <= move_threshold:
		_handle_input_movement()
	if Input.is_action_just_pressed("confirm"):
		if selected_char==null:
			select_character_at_cursor()
		else:
			try_move_selected_character(tilemap.map_to_local(position))

func _handle_input_movement():
	# Handle arrow key input for moving the cursor
	var movement = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	elif Input.is_action_pressed("ui_left"):
		movement.x -= 1
		
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	elif Input.is_action_pressed("ui_up"):
		movement.y -= 1
		
	# Normalize the movement to prevent faster diagonal movement
	if movement.length() > 0:
		movement = movement.normalized() * grid_size
		move_point += movement
	
	# Snap move point to nearest tile
	var map_position = tilemap.local_to_map(move_point)
	move_point = tilemap.map_to_local(map_position)
	
func try_move_selected_character(target):
	var empty_cell = true
	var cursor_position = tilemap.local_to_map(position)  # Read the cursor position
	print(cursor_position)
	if selected_char != null:
		var valid_cells = get_cells_in_range(selected_char)
		if cursor_position in valid_cells:
			if check_empty_cell(cursor_position)==true:
				selected_char.move_to(cursor_position)
				selected_char=null	
			else: 
				print ("cell ",cursor_position, " is occupied!")
		else:
			print ("beyond range")
		
func check_empty_cell(target):
	var characters = get_tree().get_nodes_in_group("Characters")
	for character in characters:
		if tilemap.local_to_map(character.position) == target:
			return false
		else:
			return true
			
func select_character_at_cursor() -> void:
	var cursor_cell = tilemap.local_to_map(global_position)  # Get the cell coordinates of the cursor

	var characters = get_tree().get_nodes_in_group("Characters")  
	
	
	for character in characters:
		
		var character_cell = tilemap.local_to_map(character.position)  # Get the cell coordinates of the character
		if character_cell == cursor_cell && selected_char == null:
			character.set_selected(true)
			selected_char = character
			print(selected_char)
			print(get_cells_in_range(selected_char))
			break
			
			
			
			
			
func get_cells_in_range(actor) -> Array:
	var distance = actor.AP
	var activity_points = actor.AP
	var current_cell = tilemap.local_to_map(actor.position)	
	print(current_cell)
	var reachable_cells := []
	var valid_cells := []

	for i in range(-distance, distance + 1):
		for j in range(-distance, distance + 1):
			if abs(i) + abs(j) <= distance:
				var new_x: int = (current_cell[0]+i)
				var new_y: int = (current_cell[1]+j)
				var tile_position = Vector2i(new_x,new_y)
				reachable_cells.append(tile_position)
	
	for cell in reachable_cells:
		var tile_data = tilemap.get_cell_tile_data(0, cell)
		
		if tile_data == null or tile_data.get_custom_data("walkable")==false:
			continue
		else:
			
			var path = astargrid.get_id_path(current_cell, cell).slice(1)
			var path_cost = 0
			
			for node in path:
				var node_data = tilemap.get_cell_tile_data(0, node)
				var node_cost = node_data.get_custom_data("Cost")
				
				path_cost += node_cost
			
			if path_cost <= activity_points:
				valid_cells.append(cell)
	return valid_cells
