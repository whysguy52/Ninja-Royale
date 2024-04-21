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

func save():
  print(">>> save (WIP)")


func _on_save_continue_button_pressed():
  save()
  hide()


func _on_save_button_pressed():
  save()


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
