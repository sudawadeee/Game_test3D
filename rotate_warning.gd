extends CanvasLayer

func _ready():
	# ซ่อนไว้ก่อนตอนเริ่มเกม
	visible = false

func _process(delta):
	# เช็คขนาดหน้าจอ
	var screen_size = DisplayServer.window_get_size()
	
	# ถ้า กว้าง < สูง (แสดงว่าเป็นแนวตั้ง)
	if screen_size.x < screen_size.y:
		if not visible:
			visible = true
			get_tree().paused = true # หยุดเกมชั่วคราว
			
	# ถ้า กว้าง > สูง (แนวนอนแล้ว)
	else:
		if visible:
			visible = false
			get_tree().paused = false # เล่นเกมต่อ
