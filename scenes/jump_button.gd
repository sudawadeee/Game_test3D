extends TextureButton

# ประกาศสัญญาณเดิม เพื่อให้ Player รับค่าได้เหมือนเดิม
signal jump_pressed

# ตัวแปรจำว่านิ้วไหนกำลังกดปุ่มนี้อยู่ (-1 คือไม่มี)
var _touch_index: int = -1

func _ready():
	# -----------------------------------------------------------
	# 🟢 เพิ่มส่วนนี้: ซ่อนปุ่มถ้าเล่นในคอม
	# -----------------------------------------------------------
	if not OS.has_feature("mobile"):
		visible = false
		return

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	# ---------------------------------------------------------
	# 1. ระบบสัมผัส (TOUCH) - มือถือใช้ส่วนนี้
	# ---------------------------------------------------------
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1 and get_global_rect().has_point(event.position):
				_touch_index = event.index
				jump_pressed.emit()
				modulate = Color(0.7, 0.7, 0.7)
		else:
			if event.index == _touch_index:
				_touch_index = -1
				modulate = Color(1, 1, 1)

	# ---------------------------------------------------------
	# 2. ระบบเมาส์ (MOUSE) - คอมพิวเตอร์ใช้ส่วนนี้
	# ---------------------------------------------------------
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# 🔴 แก้ไข: ถ้าเป็นมือถือ ให้ข้ามส่วนนี้ไปเลย (ป้องกันกดเบิ้ล)
		if OS.has_feature("mobile"):
			return

		if event.pressed:
			if get_global_rect().has_point(event.position):
				jump_pressed.emit()
				modulate = Color(0.7, 0.7, 0.7)
		else:
			modulate = Color(1, 1, 1)
