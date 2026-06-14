extends Node

var main_grid: Dictionary

const cell_size: Vector2 = Vector2(8, 8)
const character_offset: Vector2 = Vector2(0, 0.5) * cell_size
const character_platform_futuresight: int = 3

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
	for _x in grid:
		print(str(_x) + ": " + str(grid[_x]))

# PATH CALCULATORS

func Find_Character_Path(character_position: Vector2, goal_position: Vector2, jump_distance: float):
	return Find_Path(character_position + character_offset, goal_position + character_offset, jump_distance)

func Find_Path(first_position: Vector2, second_position: Vector2, jump_distance: float, future_num: int = 0) -> Array[Dictionary]:
	# Move positions relative to the grid
	var _first_cell_pos = round_to_cell_position(first_position)
	var _second_cell_pos = round_to_cell_position(second_position)
	
	if grid_has_pos(_first_cell_pos) and grid_has_pos(second_position):
		# Set to closest y grid position
		_first_cell_pos.y = get_nearest_value_from_array(_first_cell_pos.y, main_grid[_first_cell_pos.x])
		_second_cell_pos.y = get_nearest_value_from_array(_second_cell_pos.y, main_grid[_second_cell_pos.x])
		
		var _movement_direction = sign(_second_cell_pos.x - _first_cell_pos.x)
	return []

# ================
# HELPER FUNCTIONS
# ================

# PATHFINDING

func search_path_recursive(first_pos: Vector2, second_pos: Vector2):
	var _movement_direction = sign(second_pos.x - first_pos.x)
	var _current_pos = first_pos
	var _grid_keys = main_grid.keys()
	var _current_path = []
	if _movement_direction in [-1, 1]:
		var _next_cell_pos = _current_pos
		while(main_grid.has(_next_cell_pos) and _next_cell_pos.y in main_grid[_next_cell_pos]):
			_next_cell_pos = _current_pos + Vector2(cell_size.x * _movement_direction, 0)
		
		print("EMPTY SLOT FOUND AT: " + str(_next_cell_pos))
		
		var _nex_cell_key_num: int = _grid_keys.bsearch(_next_cell_pos.x)
		var _found_platform_x = _grid_keys[_nex_cell_key_num + 1]
		var _found_platforms_y = main_grid[_found_platform_x]
		for _platform_y in _found_platforms_y:
			search_path_recursive(path_num + 1, _found_platform_x, _platform_y)
		
	else:
		push_error("Invalid movement direction (recursive pathfinding)")
	

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
