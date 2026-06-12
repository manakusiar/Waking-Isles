extends CharacterBody2D

@export_subgroup("Nodes")
@export var main_tm: TileMapLayer

@export_subgroup("Values")
@export var goal: Vector2
@export var movement_speed: float = 120.0
@export var gravity: float

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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x += delta * 20

	#print(main_tm.get_cell_tile_data(Vector2(3, 4)))

	move_and_slide()

func Jump(goal_position: Vector2) -> void:
	_calculate_jump_variables(goal_position)

func _calculate_jump_variables(goal_position: Vector2) -> void:
	pass
