extends SubViewport

signal scene_changed

var current_scene: 
	set(scene):
		if scene is Map:
			scene_changed.emit(scene, current_scene)
			return scene
		else:
			return current_scene

func _ready() -> void:
	_fetch_current_scene()
	print("maps lodaed")

func _fetch_current_scene() -> void:
	for child in get_children():
		if child is Map:
			current_scene = child
			break

func GetCurrent() -> Node2D:
	if !current_scene:
		_fetch_current_scene()
	return current_scene
