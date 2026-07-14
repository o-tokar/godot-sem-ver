@tool
extends EditorPlugin

var __cmd_palette: EditorCommandPalette
var __popup: Window
var __packed_popup_scn: PackedScene

var __screen_center: Vector2i:
	get:
		return EditorInterface.get_base_control().get_viewport_rect().get_center() as Vector2i - (__popup.size / 2)

func _enter_tree() -> void:
	__cmd_palette = EditorInterface.get_command_palette()

	__packed_popup_scn = load("res://addons/sem_ver/edit_version_popup.tscn")

	__cmd_palette.add_command(
		"Semantic Version",
		"semantic-version/open_popup",
		Callable(self, "_show_popup")
	)

	__popup = __packed_popup_scn.instantiate() as Window
	EditorInterface.get_base_control().add_child(__popup)
	__popup.close_requested.connect(__popup.hide)


func _show_popup() -> void:
	__popup.position = __screen_center
	__popup.popup_centered(Vector2(640, 480))


func _exit_tree() -> void:
	if __cmd_palette:
		__cmd_palette.remove_command("semantic-version/open_popup")

	if __popup:
		__popup.close_requested.disconnect(__popup.hide)
		__popup.queue_free()
