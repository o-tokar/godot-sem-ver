@tool
extends Window

func _enter_tree():
	self.window_input.connect(_window_input)
	hide()

func _window_input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_requested.emit()

func _exit_tree() -> void:
	self.window_input.disconnect(_window_input)
