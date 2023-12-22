extends Node2D
var astargrid =  AStarGrid2D
@onready var cursor = get_node("/root/Main/TurnOrder/PlayerCommander/Cursor")

@onready var tilemap = get_node("/root/Main/theGrid")
func _ready() -> void:
	#special thanks @Berke in the pirate software discord for helping me get this detangled
	#instantiate Astargrid
	astargrid = AStarGrid2D.new()
	astargrid.region =  tilemap.get_used_rect()
	astargrid.cell_size = Vector2i(64,64)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

	
	maintain_grid()
	maintain_enemy_positions()

	$Character.astargrid = astargrid
	$enemy.astargrid = astargrid
	cursor.astargrid = astargrid
	
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
				if check_empty_cell(tile_position):
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
	
func maintain_grid():
	astargrid.update()
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tilemap.get_used_rect().position.x,
				y + tilemap.get_used_rect().position.y
			)
			
			var tile_data = tilemap.get_cell_tile_data(0, tile_position)
			var terrain_cost = tile_data.get_custom_data("Cost")
			if terrain_cost != null:
				astargrid.set_point_weight_scale(tile_position, terrain_cost)
			if tile_data == null or tile_data.get_custom_data("walkable")==false:
				astargrid.set_point_solid(tile_position)

func maintain_enemy_positions():
	var enemies  = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		print(tilemap.local_to_map(enemy.position))
		astargrid.set_point_solid(tilemap.local_to_map(enemy.position))


func check_empty_cell(target):
	var characters = get_tree().get_nodes_in_group("Characters")
	for character in characters:
		if tilemap.local_to_map(character.position) == target:
			return false
		else:
			return true
		
func _on_selected(agent):
	if agent != null:
		$SelectionLabel.text = "Selected: " + agent.char_name
	else:
		$SelectionLabel.text = "Selected: None" 
func _on_turn_started(agent):

	$TurnLabel.text = "Turn: " + agent.name
	
func _on_turn_ended(agent):
	print('Turn ended: ' + agent.name)

func _on_round_ended():
	print('Round ended')


func _process(delta):
	pass
