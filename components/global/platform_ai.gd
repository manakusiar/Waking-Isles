extends Node

var main_grid: Dictionary

const cell_size: Vector2 = Vector2(8, 8)
const character_offset: Vector2 = Vector2(0, 0.5) * cell_size
const character_platform_futuresight: int = 2

# ==============
# MAIN FUNCTIONS
# ==============

# GRID CALCULATORS

func Reload_Grid(tile_map_array: Array[Node], grid: Dictionary = main_grid) -> void:
	# Clearing old grid
	if grid:
		grid.clear()
	
	# Looping through every tilemap
	for _tm_layer in tile_map_array:
		if _tm_layer is TileMapLayer:
			# Getting tilemaplayer size and looping through every cell
			var _rect = _tm_layer.get_used_rect()
			for _local_cell_x in _rect.size.x:
				var _global_x: float = _tm_layer.map_to_local(Vector2i(_local_cell_x, 0) + _rect.position).x 
				for _local_cell_y in _rect.size.y:
					var _global_cell_pos: Vector2i = Vector2i(_local_cell_x, _local_cell_y) + _rect.position
					var _cell_exists: bool = _tm_layer.get_cell_source_id(_global_cell_pos) != -1
					if _cell_exists:
						var _is_platform: bool = _tm_layer.get_cell_tile_data(_global_cell_pos).get_custom_data("PlatformEndings") == true
						if _is_platform:
							if !grid.has(_global_x):
								grid[_global_x] = []
							
							var _global_y: float = _tm_layer.map_to_local(_global_cell_pos).y
							grid[_global_x].append(_global_y)
	
	grid.sort()
	#for _x in grid:
		#print(str(_x) + ": " + str(grid[_x]))

# route CALCULATORS

func Find_Character_route(character_position: Vector2, goal_position: Vector2, jump_distance: float):
	return Find_route(character_position + character_offset, goal_position + character_offset, jump_distance)

func Find_route(first_position: Vector2, second_position: Vector2, jump_distance: float) -> Array:
	# Move positions relative to the grid
	var _first_cell_pos = round_to_cell_position(first_position)
	var _second_cell_pos = round_to_cell_position(second_position)
	
	if grid_has_pos(_first_cell_pos) and grid_has_pos(second_position):
		# Set to closest y grid position
		_first_cell_pos.y = get_nearest_value_from_array(_first_cell_pos.y, main_grid[_first_cell_pos.x])
		_second_cell_pos.y = get_nearest_value_from_array(_second_cell_pos.y, main_grid[_second_cell_pos.x])
		
		var _route = [[], 0.0]
		var _final_pos = _first_cell_pos
		var _i = 0
		while(_final_pos != second_position):
			var _new_first_position: Vector2 = _final_pos
			var _new_route = search_route_recursive(_new_first_position, second_position, jump_distance, _i != 0)
			print("New route: ", _new_route)
			_final_pos = _new_route[0][-1][1]
			
			#_new_route[0].pop_front()
			_route[0].append_array(_new_route[0])
			_route[1] += _new_route[1]
			
			#print("Full route: ", _route, "\n")
			
			_i += 1
			
		return _route
	return [[], 0]

# ================
# HELPER FUNCTIONS
# ================

# PATHFINDING

func search_route_recursive(first_pos: Vector2, second_pos: Vector2, jump_distance: float, skip_first: bool = true, future_num: int = 0) -> Array:
	var _movement_direction = sign(second_pos.x - first_pos.x)
	var _grid_keys = main_grid.keys()
	var _current_route = [[], 0]
	var _distance: float = 0
	
	if int(_movement_direction) in [-1, 1]:
		# Find the end of the current platform
		var _next_cell_pos = first_pos
		var _movement_distance = cell_size.x * _movement_direction
		
		while(main_grid.has(_next_cell_pos.x + _movement_distance) and _next_cell_pos.y in main_grid[_next_cell_pos.x + _movement_distance]):
			_next_cell_pos += Vector2(_movement_distance, 0)
			_distance += cell_size.x
			if _next_cell_pos == second_pos:
				return [[[first_pos, _next_cell_pos]], _distance]
		
		# Skip appending the first platform, when it's be a duplicate
		if skip_first and future_num == 0:
			_current_route = get_emtpy_route()
		else:
			_current_route = create_route(first_pos, _next_cell_pos, _distance)
		
		# End when is final loop
		if future_num >= character_platform_futuresight:
			return _current_route
		
		var _next_cell_key_num: int = _grid_keys.bsearch(_next_cell_pos.x)
		var _jump_cells = floor(jump_distance / cell_size.x)
		var _found_platforms = []
		
		var _lowest_distance: float = INF
		var _lowest_dist_route: Array = []
		
		for i in range(_jump_cells-1):
			var _platform_x = _grid_keys[_next_cell_key_num + i + 1]
			for _platform_y in main_grid[_platform_x]:
				if !_found_platforms.has(_platform_y):
					_found_platforms.append(_platform_y)
					
					var _platform_first_position = Vector2(_platform_x, _platform_y)
					var _route = search_route_recursive(_platform_first_position, second_pos, jump_distance, skip_first, future_num + 1)
					var _route_dist = _route[1] + _next_cell_pos.distance_to(_platform_first_position)
					if _route_dist < _lowest_distance:
						_lowest_distance = _route_dist
						_lowest_dist_route = _route[0]
		
		if _lowest_distance != INF:
			add_platforms_to_route(_current_route, _lowest_dist_route, _lowest_distance)
		
		return _current_route
		
	else:
		push_error("Invalid movement direction (" + str(_movement_direction) + ")")
	return get_emtpy_route()

# ROUTE FUNCTIONS

func get_emtpy_route() -> Array:
	return [[], 0]

func create_route(first_position, second_position, distance):
	var _route = get_emtpy_route()
	add_platform_to_route(_route, first_position, second_position, distance)
	return _route

func add_platform_to_route(route, first_position, second_position, distance) -> void:
	route[0].append([first_position, second_position])
	route[1] += distance

func add_platforms_to_route(route: Array, platforms: Array, distance: float) -> void:
	route[0].append_array(platforms)
	route[1] += distance

# WORKING WITH HEIGHT ARRAYS

func get_nearest_value_from_array(value: float, array: Array) -> float:
	var nearest_value: float = INF
	var smallest_distance: float = INF
	for _value in array:
		var _distance: float = abs(value - float(_value))
		if _distance < smallest_distance:
			smallest_distance = _distance
			nearest_value = float(_value)
	return nearest_value

# WORKING WITH GRIDS

func grid_has_pos(position: Vector2, grid: Dictionary = main_grid):
	return grid.has(position.x)

# WORKING WITH CELL POSITIONS

func global_to_cell_position(global_position: Vector2) -> Vector2i:
	return Vector2i(round((global_position - cell_size/2) / cell_size))

func cell_to_global_position(cell_position: Vector2i) -> Vector2:
	return Vector2(cell_position) * cell_size + cell_size/2

func round_to_cell_position(global_position: Vector2) -> Vector2:
	return cell_to_global_position(global_to_cell_position(global_position))
