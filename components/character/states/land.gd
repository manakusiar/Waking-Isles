extends CharacterAnimationState
class_name CharacterLandingState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("land")

func on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "land":
		Transitioned.emit(self, "idle")

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("RESET")
