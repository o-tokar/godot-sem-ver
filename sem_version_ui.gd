@tool
class_name SemVersionUI extends Control

@export var __curr_version_label: Label
@export var __edit_version_label: Label
@export var __android_version_code_label: Label
@export var __android_increment_checkbox: CheckBox

@export var __major_btn: BaseButton
@export var __minor_btn: BaseButton
@export var __patch_btn: BaseButton

@export var __discard_btn: BaseButton
@export var __set_btn: BaseButton

const _export_cfg_path = "res://export_presets.cfg"
const __version_prop_path = "application/config/version"
enum Version {MAJOR, MINOR, PATCH}

var __v: Vector3i
var __v_upd: Vector3i

func _exit_tree() -> void:
	__major_btn.pressed.disconnect(__update_version)
	__minor_btn.pressed.disconnect(__update_version)
	__patch_btn.pressed.disconnect(__update_version)
	__discard_btn.pressed.disconnect(__reset)
	__set_btn.pressed.disconnect(__set_version)
	__android_increment_checkbox.toggled.disconnect(__show_android_version)
	__curr_version_label.text = ""
	__edit_version_label.text = ""
	__android_version_code_label.text = ""

func _enter_tree() -> void:
	__major_btn.pressed.connect(__update_version.bind(Version.MAJOR))
	__minor_btn.pressed.connect(__update_version.bind(Version.MINOR))
	__patch_btn.pressed.connect(__update_version.bind(Version.PATCH))

	__android_increment_checkbox.toggled.connect(__show_android_version)

	__discard_btn.pressed.connect(__reset)
	__set_btn.pressed.connect(__set_version)
	__reset()


func __show_android_version(toggle: bool):
	var _cfg = __get_export_cfg()
	__android_version_code_label.visible = toggle
	var version_code = _cfg.get_value("preset.0.options", 'version/code')
	__android_version_code_label.text = "ANDROID version code: {code}".format({"code": version_code})


func __reset():
	__edit_version_label.visible = false
	var ver = ProjectSettings.get_setting_with_override(__version_prop_path)

	__curr_version_label.text = ver

	var int3 = __extract_version(ver)
	__v_upd = Vector3i(int3[0], int3[1], int3[2])
	__v = Vector3i(int3[0], int3[1], int3[2])
	__show_android_version(__android_increment_checkbox.button_pressed)


func __get_export_cfg() -> ConfigFile:
	var _cfg = ConfigFile.new()
	var err = _cfg.load(_export_cfg_path)
	if err != OK:
		print_rich("{color} {msg}".format({"color": "[color=YELLOW]", "msg": "Export config isn't exists."}))
		return null
	else:
		return _cfg


func __update_version(version_type: Version):
	match version_type:
		Version.MAJOR:
			__v_upd.x += 1
		Version.MINOR:
			__v_upd.y += 1
		Version.PATCH:
			__v_upd.z += 1
	__edit_version_label.text = "{major}.{minor}.{patch}".format({"major": __v_upd.x, "minor": __v_upd.y, "patch": __v_upd.z})
	__edit_version_label.visible = true


func __extract_version(version_str: String) -> Array[int]:
	var regex = RegEx.new()
	regex.compile("\\d+")
	var ver_arr: Array[int] = [0, 0, 1]
	var result = regex.search_all(version_str) as Array[int]
	for i in range(result.size()):
		var number_found = int(result[i].get_string())
		ver_arr[i] = number_found

	return ver_arr


func __set_version():
	if __v == __v_upd:
		return

	# set sem-ver. game version.
	ProjectSettings.set_setting(__version_prop_path, "{0}.{1}.{2}".format([__v_upd.x, __v_upd.y, __v_upd.z]))

	var _cfg = __get_export_cfg()
	if _cfg != null and __android_increment_checkbox.button_pressed:
		var version_code = _cfg.get_value("preset.0.options", 'version/code')
		# set ANDROID version-code.
		_cfg.set_value("preset.0.options", 'version/code', version_code + 1)
		_cfg.save(_export_cfg_path)

	var err = ProjectSettings.save()
	if err != OK:
		push_error("Failed to save project settings: " + error_string(err))
		return

	# EditorInterface.get_resource_filesystem().scan()
	# EditorInterface.restart_editor(true)
	__reset()
