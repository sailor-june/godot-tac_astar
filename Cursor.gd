class_name Cursor
extends Node2D
var astargrid : AStarGrid2D
var move_speed = 200
var move_threshold = 0.01
var grid_size = 64
var selected_char = null
signal selected(agent: Node2D)
@onready var enemy_ref = get_node("/root/Main/TurnOrder/EnemyCommander/enemy")
@onready var tilemap = get_node("/root/Main/theGrid") #reference to tilemap
var move_point : Vector2 = Vector2.ZERO


#switch???? idk there should be a way to ensure only one of these is true at any given time. 
@onready var selection_phase = true
@onready var attack_phase = false








func _ready():
	move_point = position

func _process(_delta):

	if selection_phase == true:
		
		position = position.move_toward(move_point, move_speed * get_process_delta_time())
		if position.distance_to(move_point) <= move_threshold:
			_handle_input_movement()
		if Input.is_action_just_pressed("confirm"):
			if selected_char==null:
				if check_cell_occupant(tilemap.local_to_map(position), "player_characters")==true:
					select_character_at_cursor()
					
			else:
				try_move_selected_character(tilemap.map_to_local(position))
	if attack_phase == true:
		var enemy_cells = get_enemies_in_range(tilemap.local_to_map(position),"Enemies")
		print(enemy_cells)
		position = tilemap.map_to_local(enemy_cells[0])
		attack_phase= false
		selection_phase = true
		
func _handle_input_movement():
	if not visible:
		return
		
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

	if selected_char != null:
		var valid_cells = get_cells_in_range(selected_char)
		if check_cell_occupant(cursor_position,"Enemies"):
			print("cell ", cursor_position, "is occupied by an enemy unit!")
			return false
		if cursor_position == tilemap.local_to_map(selected_char.position):
			selected_char=null
			selection_phase = false
			selected.emit(selected_char)	
			show_menu_at_position(position)
			return true
		if cursor_position in valid_cells:
			selection_phase = false
			selected_char.move_to(cursor_position)
			#await move_complete()
			await selected_char.move_completed
			selected_char=null
			selected.emit(selected_char)	
			show_menu_at_position(position)

		else:
			print ("beyond range")
		
		
		
		
		
func check_cell_occupant(target, team = null):
	var characters = get_tree().get_nodes_in_group("Characters")
	if team:
		characters = get_tree().get_nodes_in_group(team)
	for character in characters:
		if tilemap.local_to_map(character.position) == target:
			return true
		else:
			return false
			
func select_character_at_cursor() -> void:
	var cursor_cell = tilemap.local_to_map(global_position)  # Get the cell coordinates of the cursor
	var characters = get_tree().get_nodes_in_group("Characters")  
	var enemies = get_tree().get_nodes_in_group("Enemies")
	
	
	for character in characters:
		
		var character_cell = tilemap.local_to_map(character.position)  # Get the cell coordinates of the character
		if character_cell == cursor_cell && selected_char == null:
			if character in enemies:
				print(" Cannot select enemy units!")
				break
			if character.has_moved:
				print ("character has already moved this turn")
				break
			character.set_selected(true)
			selected_char = character
			selected.emit(selected_char)
			
			break
			
			
	
	
	
func get_enemies_in_range(target, team):
	
	#this works for now until we add ranged attacks
	var cells_in_range = [
		Vector2i(target.x - 1, target.y),  # Left
		Vector2i(target.x, target.y - 1),  # Up
		Vector2i(target.x + 1, target.y),  # Right
		Vector2i(target.x, target.y + 1)   # Down
	]
	var valid_cells = []
	


	for pos in cells_in_range:
		# Check if there's an enemy at the adjacent position
		if check_cell_occupant(pos, team):
			valid_cells.append(pos)
	return valid_cells

			

func check_for_enemies_around(target, team):
	var adjacent_positions = [
		Vector2i(target.x - 1, target.y),  # Left
		Vector2i(target.x, target.y - 1),  # Up
		Vector2i(target.x + 1, target.y),  # Right
		Vector2i(target.x, target.y + 1)   # Down
	]

	var enemies_present = false

	for adj_pos in adjacent_positions:
		# Check if there's an enemy at the adjacent position
		if check_cell_occupant(adj_pos, team):
			enemies_present = true
			break  # Exit the loop if an enemy is found

	return enemies_present


			
			
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
				if not check_cell_occupant(tile_position):
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


func show_menu_at_position(position):

	var menu_popup = get_node("/root/Main/Movement_popup")
	menu_popup.position=position
	var isAttackEnabled = check_for_enemies_around(tilemap.local_to_map(position), "Enemies") # Check for enemies
	# Update the Attack option in the PopupMenu
	print("attack enabled?: ",isAttackEnabled)
	menu_popup.set_item_disabled(0, !isAttackEnabled)
	menu_popup.popup()
	
