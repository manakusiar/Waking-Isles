extends StateMachine
class_name CharacterAnimationStateMachine

@export var character: Charater
@export var anim_player: AnimationPlayer

func _ready() -> void:
	anim_player.animation_finished.connect(on_animation_end)
	character.hit_ground.connect(on_hit_ground)
	
	for child in get_children():
		if child is CharacterAnimationState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
	
	if initial_state:
		initial_state.Animation_Enter(character, anim_player)
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Animation_Update(delta, character, anim_player)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Animation_Physics_Update(delta, character, anim_player)

func on_animation_end(animation_name: StringName) -> void:
	current_state.on_animation_finished(animation_name)

func on_hit_ground() -> void:
	current_state.on_hit_ground()

func on_child_transitioned(state: State, new_state_name: String):
	if state != current_state:
		return
	
	var new_state = states[new_state_name.to_lower()]
	if !new_state:
		return
	
	if current_state:
		current_state.Animation_Exit(character, anim_player)
	
	new_state.Animation_Enter(character, anim_player)
	
	current_state = new_state
