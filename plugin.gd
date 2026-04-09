@tool
extends EditorPlugin
var dock

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/sem_ver/version.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()