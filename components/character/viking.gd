extends CharacterBody2D
class_name Charater

@export_subgroup("Nodes")
@export var sprite: Sprite2D

@export_subgroup("Values")
@export var goal_position: Vector2
@export var movement_speed: float = 64.0 # pixels per second
@export var gravity : float = 1000.0

# Animation variables
var was_jumping := false
signal hit_ground

# Jump variables
var is_jumping   : bool    = false
var jump_start   : Vector2 = Vector2.ZERO
var jump_goal    : Vector2 = Vector2.ZERO
var jump_vel     : Vector2 = Vector2.ZERO
var jump_elapsed : float   = 0.0
var jump_time    : float   = 0.0

# Movement variables
var next_pos: Vector2
@onready var current_route: Array = PAI.get_emtpy_route()
var current_route_time := Vector2i.ZERO

# Timers
var jump_wait_timer: Timer
var landing_wait_timer: Timer

# ===============
# ENGINE CALLBACK
# ===============

func _ready() -> void:
	next_pos = global_position
	
	jump_wait_timer = Timer.new()
	add_child(jump_wait_timer)
	jump_wait_timer.wait_time = 0.05
	jump_wait_timer.one_shot = true
	jump_wait_timer.timeout.connect(_jump_wait_timer)
	
	landing_wait_timer = Timer.new()
	add_child(landing_wait_timer)
	landing_wait_timer.wait_time = 0.05
	landing_wait_timer.one_shot = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next_pos = global_position
		get_route()
	if Input.is_action_just_pressed("ui_cancel"):
		goal_position = PAI.round_to_cell_position(get_global_mouse_position()) + PAI.character_offset
		%Sprite2D2.position = goal_position
	
	handle_movement(delta)

# ================
# COMPONENTS
# ================

func handle_movement(delta: float) -> void:
	var target_pos: Vector2 = global_position
	
	if jump_wait_timer.is_stopped() and landing_wait_timer.is_stopped():
		if is_jumping:
			jump_elapsed += delta

			if jump_elapsed >= jump_time:
				jump_elapsed = jump_time
				is_jumping = false
			
			target_pos = Vector2(
				jump_start.x + jump_vel.x * jump_elapsed,
				jump_start.y + jump_vel.y * jump_elapsed + 0.5 * gravity * jump_elapsed * jump_elapsed
			)
		else:
			if next_pos.distance_to(global_position) < movement_speed * delta:
				target_pos = lerp(global_position, next_pos, delta)
			else:
				target_pos += Vector2(sign(next_pos.x - global_position.x) * movement_speed, 0) * delta
		
		velocity = (target_pos - global_position) / delta
		move_and_slide()
		
		next_pos_check(delta)

# ================
# HELPER FUNCTIONS
# ================

# JUMPING FUNCTIONS

func jump_to(goal: Vector2, time: float) -> void:
	jump_start   = global_position
	jump_goal    = goal
	jump_time    = time
	jump_elapsed = 0.0
	is_jumping   = true
	
	jump_wait_timer.start()

func jump_to_distance(goal: Vector2) -> void:
	var dx = goal.x - global_position.x
	var dy = goal.y - global_position.y

	# From: dy = vy*t + 0.5*g*t^2  and  dx = vx*t  where vx = movement_speed * 1.25
	# Rearranging: 0.5*g*t^2 + (dy/dx * vx)*t - dy = 0
	
	var horizontal_velocity = movement_speed * 1.25
	var a = 0.5 * gravity
	var b = 0.0
	if dx != 0:
		b = -(dy / dx) * horizontal_velocity
	var c = -dy
	
	var discriminant = b * b - 4 * a * c
	var time = 0.0
	
	discriminant = abs(discriminant)
	if discriminant >= 0 and dx != 0:
		var t1 = (-b + sqrt(discriminant)) / (2 * a)
		var t2 = (-b - sqrt(discriminant)) / (2 * a)
		time = min(abs(t1), abs(t2)) * 3
	else:
		# Fallback to original calculation
		time = goal.distance_to(global_position) / (movement_speed * 1.25)
		
	jump_start   = global_position
	jump_goal    = goal
	jump_time    = time
	jump_elapsed = 0.0
	is_jumping   = true
	
	jump_wait_timer.start()

# ROUTE MANAGEMENT

func get_route() -> void:
	current_route = PAI.Find_Character_route(global_position, goal_position, 32)

func next_pos_check(delta: float) -> void:
	if next_pos.distance_to(global_position) < delta * movement_speed * 2 and current_route_time.x < current_route[0].size():
		var _should_jump := false
		if current_route_time.y >= 1:
			current_route_time.y = 0
			current_route_time.x += 1
			_should_jump = true
		else:
			current_route_time.y = 1
			hit_ground.emit()
			landing_wait_timer.start()
		
		if current_route_time.x < current_route[0].size():
			next_pos = current_route[0][current_route_time.x][current_route_time.y] - PAI.character_offset
			if _should_jump: jump_to_distance(next_pos)

# ===============
# SIGNAL CALLBACK
# ===============

func _jump_wait_timer() -> void:
	jump_vel = Vector2(
		(jump_goal.x - jump_start.x) / jump_time,
		(jump_goal.y - jump_start.y) / jump_time - 0.5 * gravity * jump_time
	)
