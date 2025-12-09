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
	# รอให้ UI จัดวางเสร็จก่อนคำนวณขนาด
	await get_tree().process_frame 
	
	if left_joy:
		left_radius = left_joy.size.x * 0.5
		_reset_left()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return

	# ----------------------------- 
	# TOUCH (สำหรับมือถือ)
	# ----------------------------- 
	if event is InputEventScreenTouch:
		if event.pressed:
			# เริ่มกด: เช็คว่าโดนปุ่มหรือไม่ และยังไม่มีนิ้วอื่นกดอยู่
			# ใช้ระยะห่างจากจุดศูนย์กลาง (Distance) แทนสี่เหลี่ยม เพื่อให้กดง่ายขึ้นแม้นิ้วจะล้นปุ่มนิดหน่อย
			var center_pos = left_joy.global_position + (left_joy.size / 2)
			if center_pos.distance_to(event.position) < left_radius * 1.5 and left_touch_id == -1:
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
	# MOUSE (สำหรับคอมพิวเตอร์)
	# ----------------------------- 
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var center_pos = left_joy.global_position + (left_joy.size / 2)
			if center_pos.distance_to(event.position) < left_radius:
				mouse_dragging = true
				_update_left(event.position)
		else:
			mouse_dragging = false
			_reset_left()

	elif event is InputEventMouseMotion:
		if mouse_dragging:
			_update_left(event.position)

func _update_left(screen_pos: Vector2) -> void:
	var center: Vector2 = left_joy.size * 0.5
	# คำนวณตำแหน่งสัมผัสเทียบกับจุดศูนย์กลางของ Joystick
	var local_pos: Vector2 = screen_pos - left_joy.global_position
	var offset: Vector2 = local_pos - center

	# จำกัดระยะ
	if offset.length() > left_radius:
		offset = offset.normalized() * left_radius

	left_inner.position = center - (left_inner.size * 0.5) + offset
	left_output = offset / left_radius

func _reset_left() -> void:
	left_dragging = false
	left_touch_id = -1
	mouse_dragging = false
	left_output = Vector2.ZERO
	if left_joy and left_inner:
		left_inner.position = (left_joy.size - left_inner.size) * 0.5

func get_output() -> Vector2:
	return left_output
