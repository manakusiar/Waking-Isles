extends CharacterBody2D

@export_subgroup("Nodes")
@export var main_tm: TileMapLayer

@export_subgroup("Values")
@export var goal_position: Vector2
@export var movement_speed: float = 64.0 # pixels per second
@export var gravity : float = 1000.0

# Jump variables
var is_jumping   : bool    = false
var jump_start   : Vector2 = Vector2.ZERO
var jump_vel     : Vector2 = Vector2.ZERO
var jump_elapsed : float   = 0.0
var jump_time    : float   = 0.0

# Movement variables
var next_pos: Vector2

# Map variables
var platform_map: Dictionary
var base_tile_texture_origin := Vector2(-4, 4)

# ===============
# ENGINE CALLBACK
# ===============

func _ready() -> void:
	create_map()
	next_pos = global_position

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		PAI.Find_Character_Path(global_position, goal_position)
	
	var target_pos: Vector2 = global_position
	
	if is_jumping:
		jump_elapsed += delta

		if jump_elapsed >= jump_time:
			jump_elapsed = jump_time
			is_jumping = false
		
		global_position = Vector2(
			jump_start.x + jump_vel.x * jump_elapsed,
			jump_start.y + jump_vel.y * jump_elapsed + 0.5 * gravity * jump_elapsed * jump_elapsed
		)
	else:
		global_position = global_position + Vector2(sign(next_pos.x - global_position.x) * 1.5, 0)
	
	#velocity = (target_pos - global_position) / delta
	#move_and_slide()
	
	#_next_pos_distance_check()

# ================
# HELPER FUNCTIONS
# ================

func create_map() -> void:
	if platform_map:
		platform_map.clear()
	
	var _size = main_tm.get_used_rect()
	for _x in _size.size.x:
		var _pos_x: float = main_tm.map_to_local(Vector2i(_x, 0) + _size.position).x 
		platform_map[str(_pos_x)] = []
		for _y in _size.size.y:
			var _cell_pos: Vector2i = Vector2i(_x, _y) + _size.position
			var _exists: bool = main_tm.get_cell_source_id(_cell_pos) != -1
			if _exists:
				var _is_platform: bool = main_tm.get_cell_tile_data(_cell_pos).get_custom_data("PlatformEndings") == true
				if _is_platform:
					var _pos_y: float = main_tm.map_to_local(_cell_pos).y
					platform_map[str(_pos_x)].append(_pos_y)
	
	#for _x in platform_map:
		#print(str(_x) + ": " + str(platform_map[_x]))

# Jump to position
func jump_to(goal: Vector2, time: float) -> void:
	jump_start   = global_position
	jump_time    = time
	jump_elapsed = 0.0
	is_jumping   = true
	
	jump_vel = Vector2(
		(goal.x - jump_start.x) / time,
		(goal.y - jump_start.y) / time - 0.5 * gravity * time
	)

func _next_pos_distance_check() -> void:
	#print(position.distance_to(next_pos))
	if abs(position.x - next_pos.x) <= 8 and !next_pos.distance_to(goal_position) < 8:
		var _cell_size = main_tm.tile_set.tile_size
		var _rect = main_tm.get_used_rect()
		var _extra_positioning = Vector2(0, 0.5) * Vector2(_cell_size)
		var _cell_positioning = _cell_size / 2
		
		var _direction = sign(goal_position.x - position.x)
		var _tm_local_position = Vector2i(main_tm.to_local(next_pos))
		
		var _current_cell_position = main_tm.local_to_map(_tm_local_position)
		var _next_cell_position = _current_cell_position + Vector2i(_direction, 0)
		var _next_cell_exists = main_tm.get_cell_source_id(_next_cell_position) != -1 and main_tm.get_cell_tile_data(_next_cell_position).get_custom_data("PlatformEndings") == true
		
		var _should_jump = abs(global_position.y - goal_position.y) > 32 and platform_map.has(str(float(next_pos.x))) and len(platform_map[str(float(next_pos.x))]) > 1
		if _next_cell_exists and !_should_jump:
			next_pos = main_tm.map_to_local(_next_cell_position) - _extra_positioning
		else:
			var _real_next_pos := 0.0
			var _real_next_pos_string := ""
			var _check := false
			while(!_check and _next_cell_position.x <= _rect.size.x + _rect.position.x):
				_real_next_pos = (_next_cell_position * _cell_size + _cell_positioning).x
				_real_next_pos_string = str(float(_real_next_pos))
				_check = platform_map.has(_real_next_pos_string) and len(platform_map[_real_next_pos_string]) > 0
				_next_cell_position = _next_cell_position + Vector2i(_direction, 0)
				
			if _check:
				var _nearest_height: float
				var _lowest_distance := INF
				for _y in platform_map[_real_next_pos_string]:
					var _dist = abs(goal_position.y - _y)
					if _dist < _lowest_distance:
						_nearest_height = _y
						_lowest_distance = _dist
				var _pos = Vector2(_real_next_pos, _nearest_height)
				if _pos.y != next_pos.y:
					jump_to(_pos - _extra_positioning, clamp(_pos.distance_to(next_pos)/96, 0.3, 0.7))
					%Sprite2D2.position = _pos
				next_pos = _pos 
