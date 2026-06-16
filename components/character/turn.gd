extends CharacterAnimationState
class_name CharacterTurnState

func Animation_Enter(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	if _character.sprite.flip_h:
		_animation_player.play_backwards("turn")
	else:
		_animation_player.play("turn")

func Animation_Update(_delta: float, _character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	if _character.is_jumping:
		Transitioned.emit(self, "jump")

func on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "turn":
		Transitioned.emit(self, "run")

func Animation_Exit(_character: CharacterBody2D, _animation_player: AnimationPlayer) -> void:
	_animation_player.play("RESET")
