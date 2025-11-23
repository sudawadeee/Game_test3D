extends CharacterBody3D

@export var min_speed = 10
@export var max_speed = 18

@export var idle_anim_name := "CharacterArmature|Flying_Idle"  # NEW
@export var no_anim_name   := "CharacterArmature|No"           # NEW

var direction_x = 1.0
var initial_rotation_y: float
var is_dead: bool = false                                      # NEW

@onready var stomp_area = $StompArea
@onready var anim: AnimationPlayer = $"Pivot/Root Scene2/AnimationPlayer"

signal squashed

func _ready() -> void:                                         # NEW
	randomize()
	_start_idle_loop()

func _physics_process(delta: float) -> void:
	# ถ้าตายแล้ว ไม่ต้องอัปเดตอะไรเพิ่ม แค่ให้ฟิสิกส์ทำงานนิดหน่อย
	if is_dead:
		move_and_slide()
		return

	move_and_slide()
	if not is_on_floor():
		velocity.y -= 25.0 * delta / 25.0
	else:
		velocity.y = 0


# ---------- ANIMATION LOOP ตอนยังไม่ตาย ----------          # NEW
func _start_idle_loop() -> void:
	# รันเป็น coroutine แยก ไม่บล็อกเกม
	_idle_loop()

func _idle_loop() -> void:
	while not is_dead:
		# เล่นท่า idle ปกติ
		if anim and anim.has_animation(idle_anim_name):
			anim.play(idle_anim_name)

		# รอแบบสุ่ม 1.5–4 วินาที ก่อนจะเล่นท่า "No"
		var wait_time := randf_range(1.5, 4.0)
		await get_tree().create_timer(wait_time).timeout
		if is_dead:
			break

		# เล่นท่า "No" หนึ่งรอบ
		if anim and anim.has_animation(no_anim_name):
			anim.play(no_anim_name)
			await anim.animation_finished
		# แล้ววนกลับไป idle อีกรอบ


# ---------- ตอนศัตรูตาย ----------
func die():
	if is_dead:
		return
	is_dead = true

	squashed.emit()

	if anim and anim.has_animation("CharacterArmature|Death"):
		anim.play("CharacterArmature|Death")
		await anim.animation_finished

	queue_free()


func _on_stomp_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player_node = body as CharacterBody3D
		var relative_y = body.global_position.y - global_position.y
		print("StompArea Detected!")
		print("Player Velocity Y:", player_node.velocity.y)
		print("Relative Y:", relative_y)
		
		if relative_y > 0.3 and player_node.velocity.y < -0.05:
			print("STOMP SUCCESS!")
			$StompArea.set_deferred("monitoring", false) 
			die()
			if player_node.has_method("_on_enemy_stomped"):
				player_node._on_enemy_stomped(self)
		else:
			if player_node.has_method("die"):
				player_node.die()
