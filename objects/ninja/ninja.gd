extends CharacterBody3D


const GRAVITY = -99
const SPEED = 5
const JUMP_SPEED = 25
const LADDER_SPEED = 2.69
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05
const DASH_SPEED = 30
const DASH_ACCEL = 15
const BLEND_SPEED = 6.9
const BLEND_SPEED_DASH = 17

var ninja_blend = preload("res://assets/3d/ninja/blend/ninja.blend")
var dir = Vector3()
var can_dash = true
var can_jump = true
var is_dashing = false
var can_climb_ladder = false

func _ready():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  adjust_ninja_material()


func adjust_ninja_material():
  var instance = ninja_blend.instantiate()
  var mesh: MeshInstance3D = instance.get_node("Armature/Skeleton3D/Arms")
  var material: StandardMaterial3D = mesh.get_active_material(0)

  material.disable_ambient_light = true


func _physics_process(delta):
  process_menu()
  process_input(delta)
  process_movement(delta)


func process_menu():
  if not $game_menu.visible and Input.is_action_just_pressed("menu"):
    $game_menu.show()


func process_input(delta):
  process_dash()
  process_walk_direction(delta)
  process_jump()


func process_dash():
  if not can_dash or is_dashing:
    return

  if Input.is_action_just_pressed("dash"):
    is_dashing = true
    $dash_timer.start()


func process_walk_direction(delta):
  dir = Vector3()
  var cam_xform = $rotation/camera.get_global_transform()
  var input_movement_vector = Vector2()

  if can_climb_ladder:
    velocity.y = 0

  if Input.is_action_pressed("move_forward"):
    if can_climb_ladder:
      velocity.y = LADDER_SPEED
    else:
      input_movement_vector.y += 1
  if Input.is_action_pressed("move_back"):
    if can_climb_ladder and !is_on_floor():
      velocity.y = -LADDER_SPEED
    else:
      input_movement_vector.y -= 1
  if Input.is_action_pressed("strafe_left"):
    input_movement_vector.x -= 1
  if Input.is_action_pressed("strafe_right"):
    input_movement_vector.x += 1

  input_movement_vector = input_movement_vector.normalized()
  dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
  dir += cam_xform.basis.x.normalized() * input_movement_vector.x

  $animation_tree.set("parameters/TimeScale/scale", 1.0 if input_movement_vector.y >= 0 else -1.0)

  if is_dashing and input_movement_vector == Vector2.ZERO:
    is_dashing = false
    $dash_timer.stop()

    var blend_amount = $animation_tree.get("parameters/blend_arms/blend_amount")
    $animation_tree.set("parameters/blend_arms/blend_amount", lerpf(blend_amount, 0.0, delta * BLEND_SPEED))
  elif is_dashing:
    var blend_amount = $animation_tree.get("parameters/blend_arms/blend_amount")
    $animation_tree.set("parameters/blend_arms/blend_amount", lerpf(blend_amount, 1.0, delta * BLEND_SPEED_DASH))
  elif not is_dashing:
    var blend_amount = $animation_tree.get("parameters/blend_arms/blend_amount")
    $animation_tree.set("parameters/blend_arms/blend_amount", lerpf(blend_amount, 0.0, delta * BLEND_SPEED))

  if input_movement_vector.y != 0:
    var blend_amount = $animation_tree.get("parameters/blend_idle_run/blend_amount")
    $animation_tree.set("parameters/blend_idle_run/blend_amount", lerpf(blend_amount, 1.0, delta * BLEND_SPEED))
  elif input_movement_vector.y == 0:
    var blend_amount = $animation_tree.get("parameters/blend_idle_run/blend_amount")
    $animation_tree.set("parameters/blend_idle_run/blend_amount", lerpf(blend_amount, 0.0, delta * BLEND_SPEED))


func process_jump():
  if can_jump and Input.is_action_just_pressed("jump") and is_on_floor():
    can_jump = false
    velocity.y = JUMP_SPEED
  elif not can_jump and is_on_floor() and $jump_cooldown_timer.is_stopped():
    $jump_cooldown_timer.start()


func process_movement(delta):
  dir.y = 0
  dir = dir.normalized()

  if !is_on_floor() and !can_climb_ladder:
    velocity.y += delta * GRAVITY

  var hvel = velocity
  hvel.y = 0

  var target = dir

  if is_dashing:
    target *= DASH_SPEED
  else:
    target *= SPEED

  var accel = DEACCEL

  if dir.dot(hvel) > 0:
    if is_dashing:
      accel = DASH_ACCEL
    else:
      accel = ACCEL

  hvel = hvel.lerp(target, accel * delta)
  velocity.x = hvel.x
  velocity.z = hvel.z

  move_and_slide()


func _input(event):
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    # TODO: maybe cache this after settings save, so we don't have to fetch from dictionaries all the time?
    var invert_vert = Settings.controls["camera"]["invert_vert"] if Settings.controls["camera"]["invert_vert"] != null else false
    var invert_horz = Settings.controls["camera"]["invert_horz"] if Settings.controls["camera"]["invert_horz"] != null else false
    var vert_val = -1 if invert_vert else 1
    var horz_val = 1 if invert_horz else -1

    $rotation.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * vert_val))
    self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * horz_val))

    var camera_rot = $rotation.rotation_degrees
    camera_rot.x = clamp(camera_rot.x, -45, 45)
    $rotation.rotation_degrees = camera_rot


func _on_dash_timer_timeout():
  is_dashing = false
  can_dash = false
  $dash_cooldown_timer.start()



func _on_dash_cooldown_timer_timeout():
  can_dash = true


func _on_jump_cooldown_timer_timeout():
  can_jump = true
