extends CharacterAnimationState
class_name CharacterIdleState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("idle")

func Animation_Update(_delta: float, _character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	if _character.is_jumping:
		Transitioned.emit(self, "jump")
	elif abs(_character.velocity.x) > 4:
		Transitioned.emit(self, "run")

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("RESET")
