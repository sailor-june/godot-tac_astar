
extends Node2D

var move_speed = 200
var move_threshold = 0.01
var grid_size = 64
var selected_char = null
@onready var tilemap = get_node("/root/Main/theGrid") #reference to tilemap
var move_point : Vector2 = Vector2.ZERO

func _ready():
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
			print("attempting move to ", tilemap.local_to_map(position))
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
	var characters = get_tree().get_nodes_in_group("Characters")
	if selected_char != null:
		for character in characters:
			if character.isSelected != true && tilemap.local_to_map(character.position) == cursor_position:
				empty_cell = false
				break
		
	if empty_cell:
		selected_char.move_to(cursor_position)
		selected_char=null	
	
	
func select_character_at_cursor() -> void:
	var cursor_cell = tilemap.local_to_map(global_position)  # Get the cell coordinates of the cursor

	var characters = get_tree().get_nodes_in_group("Characters")  
	
	
	for character in characters:
		
		var character_cell = tilemap.local_to_map(character.position)  # Get the cell coordinates of the character
		if character_cell == cursor_cell && selected_char == null:
			character.set_selected(true)
			selected_char = character
			print(selected_char)
			break
