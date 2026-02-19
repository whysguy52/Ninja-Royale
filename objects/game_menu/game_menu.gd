extends Control


var just_shown = false


func _process(_delta):
	if not visible:
		return

	if just_shown:
		just_shown = false
		return

	if Input.is_action_just_pressed("menu"):
		hide()


func _on_visibility_changed():
	if visible:
		just_shown = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_continue_button_pressed():
	hide()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_camera_vert_invert_pressed():
	Settings.toggle_controls("camera", "invert_vert")


func _on_camera_horz_invert_pressed():
	Settings.toggle_controls("camera", "invert_horz")
