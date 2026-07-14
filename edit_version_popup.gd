@tool
extends Window

@export var __edit_ui: EditVersionUI

func _enter_tree():
	self.window_input.connect(_window_input)
	self.close_requested.connect(__edit_ui.discard)
	hide()

func _window_input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_requested.emit()

func _exit_tree() -> void:
	self.window_input.disconnect(_window_input)
	self.close_requested.disconnect((__edit_ui.discard))
