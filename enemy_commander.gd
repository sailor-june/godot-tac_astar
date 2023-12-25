extends Node2D
class_name EnemyCommander

var map: TileMap

func _process_turn():
	var cells = build_cells()
	for c in get_children():
		if not c.is_in_group("Enemies"):
			continue
		print("Moving "+c.name)
		await move_unit(cells, c)
		print(c.moving, c.current_target)
	await get_tree().create_timer(2.0).timeout

func build_cells() -> Dictionary:
	var res = {}
	for c in get_tree().get_nodes_in_group("Characters"):
		res[map.local_to_map(c.position)] = {occupant = c}
	return res

func move_unit(cells: Dictionary, unit: Node2D):
	var path = find_closest_target(cells, map.local_to_map(unit.position))
	print('Move '+unit.name+': '+str(path))
	unit.current_target=path.pop_back()
	unit.current_id_path = path
	unit.moving=true
	
func find_closest_target(cells: Dictionary, origin: Vector2i) -> Array:
	var closest = {}
	search_moves(cells, origin, find_closest_target_visitor.bind(closest))
	return closest.path
	
func find_closest_target_visitor(cells, cell, res: Dictionary):
	if "path" in res:
		return false # stop searching
	
	if cell.cost == 0:
		# Origin cell, keep going
		return true
		
	if cell.coord in cells:
		if "occupant" in cells[cell.coord]:
			if not cells[cell.coord].occupant.is_in_group("Enemies"):
				# found target
				res["path"] = cell.path
				return false
			else:
				# don't path through friendlies
				return false
				
	return true	
	
func search_moves(cells: Dictionary, origin: Vector2i, visitor: Callable):
	"""
	Walk the map in ascending order of minimum path cost, calling @p visitor
	for each cell with coord, cost, path.
	Traversal proceeds through a given cell only if @p visitor returns true for
	that cell.
	"""
	var start = {coord = origin, cost = 0, path = [origin]}
	var reached = {start.coord: start}
	var pq = [start]
	while pq.size() > 0:
		# maintain priority queue (inefficiently but shouldn't matter)
		pq.sort_custom(func(a, b): return b.cost > a.cost)

		var cell = pq.pop_front()
		if not visitor.call(cells, cell):
			continue

		for neigh in map.get_surrounding_cells(cell.coord):
			var data = map.get_cell_tile_data(0, neigh)
			if data == null:
				# i.e. off the map
				continue
				
			if data.get_custom_data("walkable") == false:
				continue

			var cost = cell.cost + data.get_custom_data("Cost")

			if neigh not in reached:
				reached[neigh] = {
					coord = neigh, cost = cost, path = cell.path + [neigh]
				}
				pq.append(reached[neigh])
			elif cost < reached[neigh].cost:
				reached[neigh].cost = cost
				reached[neigh].path = cell.path + [neigh]
