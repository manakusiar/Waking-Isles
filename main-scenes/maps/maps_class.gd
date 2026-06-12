extends Node2D
class_name Map

@export var main_camera: Camera2D

func GetCameraDecimal() -> Vector2:
	var _pos = main_camera.global_position - main_camera.global_position.floor()
	print(_pos)
	return _pos
