extends Node


var controls: Dictionary = {
  "camera": {
	"invert_vert": true,
	"invert_horz": false
  }
}

func toggle_controls(path_section: String, path_name):
  var section = controls[path_section]
  var data = section[path_name]

  section[path_name] = !data
