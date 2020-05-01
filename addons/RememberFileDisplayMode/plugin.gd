tool
extends EditorPlugin


const UTIL = preload("res://addons/RememberFileDisplayMode/util.gd")
var BASE_CONTROL_VBOX : VBoxContainer
var filesystem_vsplit : VSplitContainer
var filesystem_tree : Tree
var filesystem_vbox : VBoxContainer
var settings : ConfigFile


func _enter_tree() -> void:
	settings = ConfigFile.new()
	var error = settings.load("user://RememberFileDisplayMode.cfg")
	if error == ERR_DOES_NOT_EXIST:
		settings.save("user://RememberFileDisplayMode.cfg")


func _ready() -> void:
	BASE_CONTROL_VBOX = get_editor_interface().get_base_control().get_child(1)
	filesystem_vsplit = UTIL.get_dock("FileSystemDock", BASE_CONTROL_VBOX).get_child(3)
	filesystem_tree = filesystem_vsplit.get_child(0)
	filesystem_vbox = filesystem_vsplit.get_child(1)
	filesystem_tree.connect("multi_selected", self, "_on_tree_selected")
	
	yield(get_tree().create_timer(.01), "timeout")
	var split_view : bool = settings.get_value("bf", "res://", false) as bool
	if (split_view and filesystem_vbox.get_child(0).get_child(1).icon == BASE_CONTROL_VBOX.get_icon("FileThumbnail", "EditorIcons")) \
			or (not split_view and filesystem_vbox.get_child(0).get_child(1).icon == BASE_CONTROL_VBOX.get_icon("FileList", "EditorIcons")):
		filesystem_vbox.get_child(0).get_child(1).emit_signal("pressed")
	filesystem_vbox.get_child(0).get_child(1).connect("pressed", self, "_on_button_file_list_display_mode_pressed")


func _on_tree_selected(item : TreeItem, column : int, selected : bool) -> void:
	if selected and filesystem_vbox.visible and filesystem_tree.get_selected():
		var sel : TreeItem = filesystem_tree.get_selected() 
		var dir_path = sel.get_text(0)
		while sel.get_parent() != filesystem_tree.get_root():
			dir_path = sel.get_parent().get_text(0) + ("/" if sel.get_parent().get_text(0) != "res://" else "") + dir_path
			sel = sel.get_parent()
		var split_view : bool = settings.get_value("bf", dir_path, false) as bool
		if (split_view and filesystem_vbox.get_child(0).get_child(1).icon == BASE_CONTROL_VBOX.get_icon("FileThumbnail", "EditorIcons")) \
				or (not split_view and filesystem_vbox.get_child(0).get_child(1).icon == BASE_CONTROL_VBOX.get_icon("FileList", "EditorIcons")):
			filesystem_vbox.get_child(0).get_child(1).emit_signal("pressed")


func _on_button_file_list_display_mode_pressed() -> void:
	var selected : TreeItem = filesystem_tree.get_selected() 
	var dir_path = selected.get_text(0)
	while selected.get_parent() != filesystem_tree.get_root():
		dir_path = selected.get_parent().get_text(0) + ("/" if selected.get_parent().get_text(0) != "res://" else "") + dir_path
		selected = selected.get_parent()
	settings.set_value("bf", dir_path, "" if filesystem_vbox.get_child(0).get_child(1).icon == BASE_CONTROL_VBOX.get_icon("FileThumbnail", "EditorIcons") else "true")
	settings.save("user://RememberFileDisplayMode.cfg")
