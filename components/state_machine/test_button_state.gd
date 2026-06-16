extends State

@export var test_button: Button
@export var test_check_box: CheckBox

func _ready() -> void:
	test_button.pressed.connect(_on_button_press)
	GlobalTestMenu.OnGamePaused.connect(_on_game_pause)
	_on_game_pause(false)

func Update(delta: float) -> void:
	pass

func Physics_Update(delta: float) -> void:
	pass

func Enter() -> void:
	test_check_box.button_pressed = true

func Exit() -> void:
	test_check_box.button_pressed = false

func _on_button_press() -> void:
	Transitioned.emit(self, "button" + str(int(name.right(1)) % get_parent().get_child_count() + 1))

func _on_game_pause(paused) -> void:
	self.visible = paused
