#touch_controls
extends Control

@onready var left_joy: Control = $LeftJoy
@onready var left_inner: Control = $LeftJoy/Inner

# ปรับค่านี้: ถ้ารู้สึกว่าต้องลากไกลไปกว่าจะวิ่ง ให้ลดเลขนี้ลง (เช่น 60.0)
var left_radius: float = 100.0 

# Deadzone: กันจอยสั่นเองเวลาแตะโดนนิดเดียว
var deadzone: float = 0.1

var left_output: Vector2 = Vector2.ZERO
var left_touch_id: int = -1
var is_dragging: bool = false

func _ready() -> void:
	# -----------------------------------------------------------
	# 🟢 แก้ไขใหม่: สั่งให้ชัดเจนทั้ง 2 ทาง (กันพลาด)
	# -----------------------------------------------------------
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		visible = true   # ถ้าเป็นมือถือ -> บังคับแสดงปุ่มเสมอ
	else:
		visible = false  # ถ้าเป็นคอม -> บังคับซ่อน
		set_process_input(false)
		return
	# -----------------------------------------------------------

	await get_tree().process_frame
	
	if left_joy:
		left_radius = left_joy.size.x * 0.5
		
	_reset_left()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return

	# ---------------------------------------------------------
	# 1. ระบบสัมผัส (TOUCH) - แก้บั๊กค้างและตอบสนองไวขึ้น
	# ---------------------------------------------------------
	if event is InputEventScreenTouch:
		if event.pressed:
			# เริ่มกด: เช็คระยะห่างแทนกรอบสี่เหลี่ยม (วงกลมกดง่ายกว่า)
			var center = left_joy.global_position + (left_joy.size / 2)
			var dist = event.position.distance_to(center)
			
			# ยอมให้กดเกินขอบปุ่มมานิดหน่อยได้ (1.2 เท่า) จะได้กดติดง่ายๆ
			if left_touch_id == -1 and dist < left_radius * 1.5:
				left_touch_id = event.index
				is_dragging = true
				_update_joy(event.position) # อัปเดตทันทีที่แตะ (ไม่ต้องรอลาก)
		
		else:
			# ปล่อยมือ: เช็คแค่ว่าเป็นนิ้วเดิมหรือไม่ (ไม่สนตำแหน่ง)
			if event.index == left_touch_id:
				_reset_left()

	elif event is InputEventScreenDrag:
		if is_dragging and event.index == left_touch_id:
			_update_joy(event.position)

	# ---------------------------------------------------------
	# 2. ระบบเมาส์ (MOUSE) - สำหรับเทสในคอม
	# ---------------------------------------------------------
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var center = left_joy.global_position + (left_joy.size / 2)
			if center.distance_to(event.position) < left_radius:
				is_dragging = true
				left_touch_id = -2 # ใช้ ID ปลอมสำหรับเมาส์
				_update_joy(event.position)
		else:
			if left_touch_id == -2:
				_reset_left()

	elif event is InputEventMouseMotion:
		if is_dragging and left_touch_id == -2:
			_update_joy(event.position)

# ==========================================
# ฟังก์ชันคำนวณตำแหน่งและค่า Output
# ==========================================
func _update_joy(touch_pos: Vector2) -> void:
	var center_pos = left_joy.global_position + (left_joy.size / 2)
	var local_vector = touch_pos - center_pos
	
	# ถ้าลากเกินวงกลม ให้ตัดขอบ
	if local_vector.length() > left_radius:
		local_vector = local_vector.normalized() * left_radius
	
	# ขยับปุ่ม Inner
	left_inner.global_position = center_pos - (left_inner.size / 2) + local_vector
	
	# คำนวณ Output (Normalize 0-1)
	var val = local_vector / left_radius
	
	# Apply Deadzone (กันค่าสั่น)
	if val.length() < deadzone:
		left_output = Vector2.ZERO
	else:
		left_output = val

# ==========================================
# RESET
# ==========================================
func _reset_left() -> void:
	is_dragging = false
	left_touch_id = -1
	left_output = Vector2.ZERO
	
	# ดีดปุ่มกลับตรงกลาง
	if left_joy and left_inner:
		left_inner.position = (left_joy.size - left_inner.size) / 2

# ส่งค่าให้ Player
func get_output() -> Vector2:
	return left_output
	
# -----------------------------------------------------------
# 🟢 เพิ่มฟังก์ชันนี้: ดักจับเหตุการณ์ของระบบ (Notification)
# -----------------------------------------------------------
func _notification(what: int) -> void:
	# เมื่อเกมถูกสั่ง Pause (เช่น ตอนเปิดหน้าคำถาม)
	# หรือเมื่อเกมกลับมาเล่นต่อ (Unpause)
	# หรือเมื่อหน้าจอนี้ถูกซ่อน (Visibility Changed)
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED or what == NOTIFICATION_VISIBILITY_CHANGED:
		_reset_left()
