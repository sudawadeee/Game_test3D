#touch_controls
extends Control

@onready var left_joy: Control = $LeftJoy
@onready var left_inner: Control = $LeftJoy/Inner

var left_radius: float = 80.0
var left_output: Vector2 = Vector2.ZERO

var left_dragging: bool = false
var left_touch_id: int = -1
var mouse_dragging: bool = false 

func _ready() -> void:
	await get_tree().process_frame 
	
	# คำนวณรัศมีจากขนาดของ Joystick (ครึ่งหนึ่งของความกว้าง)
	left_radius = left_joy.size.x * 0.5
	_reset_left()

func _input(event: InputEvent) -> void:
	# ----------------------------- 
	# TOUCH (สำหรับมือถือ)
	# ----------------------------- 
	if event is InputEventScreenTouch:
		if event.pressed:
			# เริ่มกด: เช็คว่าโดนปุ่มหรือไม่ และยังไม่มีนิ้วอื่นกดอยู่
			if _inside_left(event.position) and left_touch_id == -1:
				left_dragging = true
				left_touch_id = event.index
				_update_left(event.position)
		else:
			# ปล่อยมือ: ต้องเป็นนิ้วเดียวกับที่กดตอนแรก
			if event.index == left_touch_id:
				_reset_left()

	elif event is InputEventScreenDrag:
		if left_dragging and event.index == left_touch_id:
			_update_left(event.position)

	# ----------------------------- 
	# MOUSE (สำหรับคอมพิวเตอร์ / Debug)
	# ----------------------------- 
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _inside_left(event.position):
					mouse_dragging = true
					_update_left(event.position)
			else:
				mouse_dragging = false
				_reset_left()

	elif event is InputEventMouseMotion:
		if mouse_dragging:
			# ใช้ event.position โดยตรง แม่นยำกว่าการบวก relative
			_update_left(event.position)

# ==========================================
# เช็คว่าจิ้มใน joystick หรือไม่
# ==========================================
func _inside_left(screen_pos: Vector2) -> bool:
	# Godot 4: ใช้ get_global_rect() เพื่อเช็คขอบเขตได้เลย ง่ายและแม่นยำกว่า
	return left_joy.get_global_rect().has_point(screen_pos)

func _update_left(screen_pos: Vector2) -> void:
	# แปลงพิกัดหน้าจอ เป็นพิกัดภายในของ LeftJoy
	var local_pos: Vector2 = screen_pos - left_joy.global_position
	var center: Vector2 = left_joy.size * 0.5
	
	# หาเวกเตอร์จากจุดกึ่งกลางไปยังจุดที่นิ้วกด
	var offset: Vector2 = local_pos - center

	# จำกัดระยะการเคลื่อนที่ให้ภายในรัศมี
	if offset.length() > left_radius:
		offset = offset.normalized() * left_radius

	# ขยับตำแหน่งของ inner joystick (ปุ่มตรงกลาง)
	left_inner.position = center - (left_inner.size * 0.5) + offset

	# คำนวณ Output (-1 ถึง 1)
	left_output = offset / left_radius
	
	# ปริ้นค่าออกมาดู (ลบออกได้เมื่อใช้งานจริง)
	# print("Joystick Output: ", left_output)

# ==========================================
# RESET JOYSTICK
# ==========================================
func _reset_left() -> void:
	left_dragging = false
	left_touch_id = -1
	mouse_dragging = false
	left_output = Vector2.ZERO

	# รีเซ็ตตำแหน่ง Inner กลับไปตรงกลาง
	if left_joy and left_inner:
		left_inner.position = (left_joy.size - left_inner.size) * 0.5

# ฟังก์ชันสำหรับให้ตัวละครดึงค่าไปใช้
func get_output() -> Vector2:
	return left_output
