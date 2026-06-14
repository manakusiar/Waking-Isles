extends Map

@export var TileMapGroup: Node2D

func _ready() -> void:
	PAI.Reload_Grid(TileMapGroup.get_children())
