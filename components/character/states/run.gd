extends CharacterAnimationState
class_name CharacterRunningState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("run", -1.0, 0.75)

func Animation_Update(_delta: float, _character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	if _character.is_jumping:
		Transitioned.emit(self, "jump")
	elif abs(_character.velocity.x) <= 4:
		Transitioned.emit(self, "idle")
	elif _character.sprite.flip_h != (_character.global_position > _character.next_pos):
		Transitioned.emit(self, "turn")

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("RESET")
