extends CharacterAnimationState
class_name CharacterJumpingState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("jump")

func on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "jump":
		Transitioned.emit(self, "freefall")

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("RESET")
