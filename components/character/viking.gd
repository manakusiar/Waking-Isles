extends CharacterBody2D

@export_subgroup("Nodes")
@export var main_tm: TileMapLayer

@export_subgroup("Values")
@export var goal: Vector2
@export var movement_speed: float = 60 * 60
@export var gravity: float = 10.0
@export var extra_height: float = 64.0


var platform_map: Array[Dictionary]

func create_map() -> void:
	if platform_map:
		platform_map.clear()
	
	var _size = main_tm.get_used_rect()
	for _x in _size.size.x:
		var _pos_x: float = main_tm.map_to_local(Vector2i(_x, 0)).x
		platform_map.append({
			"x": _pos_x,
			"platforms": []
		})
		for _y in _size.size.y:
			var _cell_pos: Vector2i = Vector2i(_x, _y)
			var _exists: bool = main_tm.get_cell_source_id(_cell_pos) != -1
			if _exists:
				var _is_platform: bool = main_tm.get_cell_tile_data(_cell_pos).get_custom_data("PlatformEndings") == true
				if _is_platform:
					var _pos_y: float = main_tm.map_to_local(Vector2i(_x, _y)).y
					platform_map[-1]["platforms"].append(_pos_y)
	
	for _x in platform_map:
		print(_x)

func _ready() -> void:
	create_map()
	var _delta := 60
	Jump(goal, _delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x = delta * movement_speed

	#print(main_tm.get_cell_tile_data(Vector2(3, 4)))

	move_and_slide()

func Jump(goal_position: Vector2, delta: float) -> void:
	_calculate_jump_variables(goal_position, delta)

func _calculate_jump_variables(goal_position: Vector2, delta: float) -> void:
	var _og_y = position.y
	var _goal_y = goal_position.y
	var _height = max(_og_y, _goal_y)
	var _h_vel = movement_speed / delta
	gravity = 2*(_height - _og_y) * abs(position.x - goal_position.x)**2 / (_h_vel**2)
	velocity.y = -2*(_height - _og_y) * abs(position.x - goal_position.x) / (_h_vel)
