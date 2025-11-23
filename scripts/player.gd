extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D   # ไม่ใช้แล้ว แต่เก็บไว้ถ้าอยากใช้ model/mesh

@export_subgroup("Properties")
@export var movement_speed = 5.0
@export var jump_strength = 7.0

# Camera control
@onready var camera_pivot = $CameraPivot
@export var mouse_sensitivity: float = 0.003
@export var clamp_angle: float = 80.0

var yaw := 0.0   # ซ้าย-ขวา
var pitch := 0.0 # ขึ้น-ลง

var movement_velocity: Vector3
var gravity = 0.0

var previously_floored = false
var jump_single = true
var jump_double = true

var coins = 0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer

# ==============================
# Lifecycle
# ==============================

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)
	handle_effects(delta)

	# Movement
	var applied_velocity: Vector3 = velocity
	applied_velocity.x = movement_velocity.x
	applied_velocity.z = movement_velocity.z
	applied_velocity.y = -gravity

	velocity = applied_velocity
	move_and_slide()

	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()

	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

	# Animation when landing
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")

	previously_floored = is_on_floor()

func _input(event: InputEvent) -> void:
	# Toggle mouse mode ด้วยปุ่ม Shift
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# หมุนกล้องเฉพาะตอน mouse ถูกจับ
	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity      # ซ้าย/ขวา
		pitch += event.relative.y * mouse_sensitivity    # ขึ้น/ลง

		pitch = clamp(pitch, deg_to_rad(-clamp_angle), deg_to_rad(clamp_angle))

		rotation.y = yaw                     # Player หมุนตามเมาส์ซ้าย-ขวา
		camera_pivot.rotation.x = pitch      # กล้องหมุนขึ้น-ลง
# ==============================
# Effects / Animations
# ==============================

func handle_effects(delta):
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed
		if speed_factor > 0.05:
			if animation.current_animation != "walk":
				animation.play("walk", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		elif animation.current_animation != "idle":
			animation.play("idle", 0.1)

		if animation.current_animation == "walk":
			animation.speed_scale = speed_factor
		else:
			animation.speed_scale = 1.0

	elif animation.current_animation != "jump":
		animation.play("jump", 0.1)

# ==============================
# Movement
# ==============================

func handle_controls(delta):
	var input_dir := Vector3.ZERO

	input_dir.x = Input.get_axis("move_right", "move_left" )
	input_dir.z = Input.get_axis("move_back", "move_forward")

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	# FPS: ใช้การหมุนของ Player (rotation.y) กำหนดทิศทางเดิน
	movement_velocity = transform.basis * input_dir * movement_speed

	# Jumping
	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			jump()

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

# ==============================
# Collect coins
# ==============================

func collect_coin():
	coins += 1
	coin_collected.emit(coins)
	
# stomp enemy
func _on_enemy_stomped(enemy: Node):
	gravity = -jump_strength * 0.7
	model.scale = Vector3(0.5, 1.5, 0.5)
	if enemy.has_method("CharacterArmature|Death"):
		enemy.die()
