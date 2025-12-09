extends Node3D

var falling := false
var fall_velocity := 0.0

func _physics_process(delta):
	scale = scale.lerp(Vector3(1, 1, 1), delta * 10) # Animate scale
	
	if falling:
		fall_velocity += 1000.0 * delta
		position.y -= fall_velocity * delta
	else:
		fall_velocity = 0.0
	
	if position.y < -10:
		queue_free() # Remove platform if below threshold

func _on_body_entered(body): # ลบ _ หน้า body ออก เพราะเราจะเรียกใช้งานมันแล้ว
	# เช็คว่าสิ่งที่ชน คือ "Player" เท่านั้น
	if body.is_in_group("Player"): 
		if !falling:
			Audio.play("res://sounds/fall.ogg") 
			scale = Vector3(1.25, 1, 1.25) 
		
		falling = true
