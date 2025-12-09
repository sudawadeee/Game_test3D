extends TextureButton

# ประกาศสัญญาณเดิม เพื่อให้ Player รับค่าได้เหมือนเดิม
signal jump_pressed

# ตัวแปรจำว่านิ้วไหนกำลังกดปุ่มนี้อยู่ (-1 คือไม่มี)
var _touch_index: int = -1

func _input(event: InputEvent) -> void:
	# ถ้าปุ่มซ่อนอยู่ ไม่ต้องทำงาน
	if not is_visible_in_tree():
		return

	# -----------------------------------------------
	# 1. ระบบสัมผัส (Touch) - รองรับหลายนิ้วพร้อมกัน
	# -----------------------------------------------
	if event is InputEventScreenTouch:
		if event.pressed:
			# เงื่อนไข: ยังไม่มีนิ้วไหนกดปุ่มนี้ AND ตำแหน่งที่แตะอยู่ในกรอบปุ่ม
			if _touch_index == -1 and get_global_rect().has_point(event.position):
				_touch_index = event.index # จำเลขนิ้วไว้
				jump_pressed.emit()        # ส่งสัญญาณกระโดด
				
				# เอฟเฟกต์ปุ่มยุบ (เปลี่ยนสีให้เข้มขึ้นนิดนึง)
				modulate = Color(0.7, 0.7, 0.7) 
				
		else:
			# ตอนปล่อย: ต้องเป็นนิ้วเดียวกับที่กดตอนแรกเท่านั้น
			if event.index == _touch_index:
				_touch_index = -1
				
				# คืนค่าสีปุ่ม
				modulate = Color(1, 1, 1) 

	# -----------------------------------------------
	# 2. เมาส์ (Mouse) - สำหรับทดสอบในคอม
	# -----------------------------------------------
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_global_rect().has_point(event.position):
				jump_pressed.emit()
				modulate = Color(0.7, 0.7, 0.7)
		else:
			modulate = Color(1, 1, 1)
