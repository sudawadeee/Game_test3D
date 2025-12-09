# Player
extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed: float = 5.0
@export var jump_strength: float = 7.0

@onready var touch_controls = $"../CanvasLayer4/TouchControls"
@onready var look_area = $"../CanvasLayer4/LookArea"
@onready var jump_btn = %JumpButton

# ==========================
# CAMERA
# ==========================
@onready var camera_pivot = $CameraPivot
@export var mouse_sensitivity: float = 0.003
@export var clamp_angle: float = 80.0

var yaw: float = 0.0
var pitch: float = 0.0

# ==========================
# Smooth touch rotation variables
# ==========================
var look_delta: Vector2 = Vector2.ZERO
var look_smooth: Vector2 = Vector2.ZERO
var look_smooth_strength := 14.0   # PUBG-like smoothing

# ==========================
# MOVEMENT
# ==========================
var movement_velocity: Vector3
var gravity: float = 0.0

var previously_floored := false
var jump_single := true
var jump_double := true

var coins := 0
var ui_block := false

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Banana
@onready var animation = $Banana/AnimationPlayer

var respawn_position: Vector3

# ==========================
# READY
# ==========================
func _ready():
	print("JumpButton =", jump_btn)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	respawn_position = global_transform.origin

	# Connect for mobile look + jump button
	look_area.look_input.connect(_on_look_input)
	jump_btn.jump_pressed.connect(_on_jump_button)
	

# ==========================
# PHYSICS PROCESS
# ==========================
func _physics_process(delta):
	if ui_block:
		return

	handle_controls(delta)
	handle_gravity(delta)
	handle_effects(delta)

	# Apply movement
	var applied_velocity: Vector3 = velocity
	applied_velocity.x = movement_velocity.x
	applied_velocity.z = movement_velocity.z
	applied_velocity.y = -gravity

	velocity = applied_velocity
	move_and_slide()

	# Respawn if falling
	if position.y < -10:
		die()

	# Landing squish animation
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")

	previously_floored = is_on_floor()


# ==========================
# PROCESS (Camera Smooth)
# ==========================
func _process(delta: float) -> void:

	# Smooth camera rotation (PUBG-like)
	look_smooth = look_smooth.lerp(look_delta, look_smooth_strength * delta)

	if look_smooth.length() > 0.01:
		yaw -= look_smooth.x * mouse_sensitivity
		pitch = clamp(
			pitch - look_smooth.y * mouse_sensitivity,
			deg_to_rad(-clamp_angle),
			deg_to_rad(clamp_angle)
		)

		rotation.y = yaw
		camera_pivot.rotation.x = pitch

	# Reset after applying
	look_delta = Vector2.ZERO



# ==========================
# INPUT (Mouse only)
# ==========================
func _input(event: InputEvent) -> void:
	if ui_block:
		return

	# ESC toggles mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Mouse camera for PC
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		look_delta = event.relative


# ==========================
# MOVEMENT (Joystick & Keyboard)
# ==========================
func handle_controls(delta):
	var joy: Vector2 = touch_controls.left_output  # Joystick input from mobile controls
	print("Joystick output from Player: ", joy)  # ดีบั๊กค่า joy

	var move_vec := Vector3.ZERO

	var yaw_angle := rotation.y
	var forward := Vector3(-sin(yaw_angle), 0, -cos(yaw_angle))
	var right := Vector3(-cos(yaw_angle), 0, sin(yaw_angle))

	# Handle touch control (mobile)
	if joy.length() > 0.1:
		move_vec = right * joy.x + forward * joy.y
	else:
		# Use keyboard input if no touch input is detected
		var kb_x := Input.get_axis("move_left", "move_right")
		var kb_y := Input.get_axis("move_forward", "move_back")
		move_vec = right * kb_x + forward * kb_y

	# Normalize movement vector if the length exceeds 1 (diagonal movement)
	if move_vec.length() > 1:
		move_vec = move_vec.normalized()

	movement_velocity = move_vec * movement_speed

	# Handle jump input
	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			jump()



# ==========================
# GRAVITY / JUMP
# ==========================
func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0


func jump():
	Audio.play("res://sounds/jump.ogg")
	gravity = -jump_strength
	model.scale = Vector3(0.5, 1.5, 0.5)

	if jump_single:
		jump_single = false
		jump_double = true
	else:
		jump_double = false



# ==========================
# EFFECTS / ANIMATION
# ==========================
func handle_effects(_delta):
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		var horizontal := Vector2(velocity.x, velocity.z)
		var speed_factor := horizontal.length() / movement_speed

		if speed_factor > 0.05:
			if animation.current_animation != "run":
				animation.play("run", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		else:
			if animation.current_animation != "Locomotion-Library/idle2":
				animation.play("Locomotion-Library/idle2", 0.1)

		animation.speed_scale = speed_factor if animation.current_animation == "run" else 1.0

	elif animation.current_animation != "Locomotion-Library/jump-short":
		animation.play("Locomotion-Library/jump-short", 0.1)


# ==========================
# COINS / LIFE / CHECKPOINT
# ==========================
func collect_coin():
	coins += 1
	coin_collected.emit(coins)


func set_checkpoint(pos: Vector3):
	respawn_position = pos
	print("Checkpoint updated:", pos)


func die():
	print("Player died — respawning")
	global_transform.origin = respawn_position
	velocity = Vector3.ZERO
	gravity = 0.0


# ==========================
# COLLISION WITH ENEMY
# ==========================
func _on_enemy_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		die()


func _on_enemy_stomped(enemy):
	print("Enemy stomped:", enemy)
	gravity = -jump_strength * 1.2
	jump_single = false
	jump_double = false


# ==========================
# MOBILE INPUT CALLBACKS
# ==========================
func _on_look_input(delta: Vector2) -> void:
	look_delta = delta


func _on_jump_button() -> void:
	if jump_single or jump_double:
		jump()
