extends State
class_name CharacterAnimationState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	pass

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	pass

func Animation_Update(_delta: float, _character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	pass

func Animation_Physics_Update(_delta: float, _character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	pass

func on_animation_finished(_anim_name: StringName) -> void:
	pass

func on_hit_ground() -> void:
	pass
