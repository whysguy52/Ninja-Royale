extends CharacterBody3D

const GRAVITY = -32.8
const MAX_SPEED = 5
const JUMP_SPEED = 7
const LADDER_SPEED = 2.69
const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05
const MAX_SPRINT_SPEED = 10
const SPRINT_ACCEL = 9

var dir = Vector3()
var is_sprinting = false
var can_climb_ladder = false

var camera
var rotation_helper

# Called when the node enters the scene tree for the first time.
func _ready():
  camera = $rotation/camera
  rotation_helper = $rotation

  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
  process_menu()
  process_input()
  process_movement(delta)


func process_menu():
  if Input.is_action_just_pressed("menu"):
    if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func process_input():
  process_sprint()
  process_walk_direction()
  process_jump()

func process_sprint():
  if !is_sprinting and Input.is_action_just_pressed("sprint"):
    is_sprinting = true
    $sprint_timer.start()

func process_walk_direction():
  dir = Vector3()
  var cam_xform = camera.get_global_transform()
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

  if is_sprinting and input_movement_vector.y == 0:
    is_sprinting = false
    $sprint_timer.stop()

  input_movement_vector = input_movement_vector.normalized()
  dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
  dir += cam_xform.basis.x.normalized() * input_movement_vector.x

func process_jump():
  if Input.is_action_pressed("jump") and is_on_floor():
    velocity.y = JUMP_SPEED

func process_movement(delta):
  dir.y = 0
  dir = dir.normalized()

  if !is_on_floor() and !can_climb_ladder:
    velocity.y += delta * GRAVITY

  var hvel = velocity
  hvel.y = 0

  var target = dir

  if is_sprinting:
    target *= MAX_SPRINT_SPEED
  else:
    target *= MAX_SPEED

  var accel
  if dir.dot(hvel) > 0:
    if is_sprinting:
      accel = SPRINT_ACCEL
    else:
      accel = ACCEL
  else:
    accel = DEACCEL

  hvel = hvel.lerp(target, accel * delta)
  velocity.x = hvel.x
  velocity.z = hvel.z

  move_and_slide()

func _input(event):
  if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
    rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY))
    self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))

    var camera_rot = rotation_helper.rotation_degrees
    camera_rot.x = clamp(camera_rot.x, -45, 45)
    rotation_helper.rotation_degrees = camera_rot
