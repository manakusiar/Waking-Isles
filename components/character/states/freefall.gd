extends CharacterAnimationState
class_name CharacterFrefallState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("fall")

func Animation_Update(_delta: float, _character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	if _character.velocity.y > 0 and _animation_player.current_animation != "fall":
		_animation_player.play("fall")
	elif _animation_player.current_animation != "rise":
		_animation_player.play("rise")

func on_hit_ground() -> void:
	Transitioned.emit(self, "land")

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("RESET")
