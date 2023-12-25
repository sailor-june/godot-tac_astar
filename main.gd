extends Node2D
var astargrid =  AStarGrid2D
@onready var cursor = get_node("/root/Main/TurnOrder/PlayerCommander/Cursor")

@onready var grid = get_node("/root/Main/theGrid")
func _ready() -> void:
	#special thanks @Berke in the pirate software discord for helping me get this detangled
	#instantiate Astargrid
	astargrid = AStarGrid2D.new()
	astargrid.region =  grid.get_used_rect()
	astargrid.cell_size = Vector2i(64,64)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.update()
	
	maintain_terrain()
	maintain_enemy_positions()


	for char in get_tree().get_nodes_in_group("Characters"):
		char.astargrid = astargrid
	cursor.astargrid = astargrid
	
	$TurnOrder/EnemyCommander.map = $theGrid
func maintain_terrain():
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

func maintain_enemy_positions():
	var enemies  = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		print(grid.local_to_map(enemy.position))
		astargrid.set_point_solid(grid.local_to_map(enemy.position))



		
func _on_selected(agent):
	if agent != null:
		$SelectionLabel.text = "Selected: " + agent.char_name
	else:
		$SelectionLabel.text = "Selected: None" 
func _on_turn_started(agent):
	maintain_terrain()
	maintain_enemy_positions()
	$TurnLabel.text = "Turn: " + agent.name
	
func _on_turn_ended(agent):
	print('Turn ended: ' + agent.name)

func _on_round_ended():
	print('Round ended')
	

func _process(delta):
	pass
