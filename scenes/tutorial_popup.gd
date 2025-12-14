# tutorial.gd
extends Control

# ตัวแปรเก็บข้อมูลที่จะใช้จริง
var pages: Array = []
var page_images: Array = []
var page_image_sizes: Array = [] 

var index := 0

@onready var _label: Label = $Panel/data
@onready var _image: TextureRect = $Panel/ImageRect
@onready var _btn_next: Button = $Panel/BtnNext
@onready var _btn_exit: Button = $Panel/BtnExit
@onready var _panel: Panel = $Panel 

signal tutorial_finished

# ---------------------------
# INITIALIZE
# ---------------------------
func _ready() -> void:
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	load_level_data()
	show_page(0)
	
	if not _btn_next.pressed.is_connected(next_page):
		_btn_next.pressed.connect(next_page)
	if not _btn_exit.pressed.is_connected(exit_tutorial):
		_btn_exit.pressed.connect(exit_tutorial)

# ---------------------------
# 🛠️ โหลดข้อมูลตามด่าน
# ---------------------------
func load_level_data():
	var current_lvl = Game.current_level_index
	
	match current_lvl:
		0: # === ด่าน 1 ===
			pages = [
				"ยินดีต้อนรับสู่ด่านแรก!\n(กด ESC เพื่อเปิดใช้งานเมาส์)",
				"การควบคุมในคอม:\n W A S D = เดิน",
				"การกระโดด:Spacebar = กระโดดปกติ\n กด Spacebar 2 ครั้ง = กระโดดสูง\n(Spacebar คือปุ่มยาวด้านล่างของคีย์บอร์ด)",
				"การควบคุมในโทรศัพท์:\nใช้จอยสติ๊กด้านซ้ายเพื่อเดิน\nใช้ปุ่มด้านขวาเพื่อกระโดด",
				"การควบคุมในโทรศัพท์:",
				"ศัตรู:\nกระโดดเหยียบหัวเพื่อกำจัดมัน",
				"การผ่านด่าน:\nกระโดดไปตามแท่นต่าง ๆ กำจัดศัตรู\nตอบคำถามทั้งหมด 5 ข้อ\nพยายามตอบให้ถูกอย่างน้อย 4 ข้อ\nเพื่อเก็บไอเทมและชนะเกม"
			]
			page_images = [
				preload("res://tutorial/welcome.png"),
				preload("res://tutorial/wasd-keys-_wasdkey.webp"),
				preload("res://tutorial/spacebar.jpg"),
				preload("res://tutorial/3.png"),
				preload("res://tutorial/2.png"),
				preload("res://tutorial/Screenshot 2025-11-24 235102.png"),
				preload("res://tutorial/quetion.png")
			]
			# 🟢 เพิ่มขนาดอันที่ 7 ให้ครบตามจำนวนหน้า (ไม่งั้น Error)
			page_image_sizes = [
				Vector2(1200, 1200),  # หน้า 1
				Vector2(1500, 1500),  # หน้า 2
				Vector2(1500, 1500),  # หน้า 3
				Vector2(1800, 1800),  # หน้า 4
				Vector2(1800, 1800),  # หน้า 5
				Vector2(1500, 1500),  # หน้า 6
				Vector2(1000, 1000)   # หน้า 7 (เพิ่มใหม่)
			]

		1: # === ด่าน 2 ===
			pages = [
				"ยินดีต้อนรับสู่ด่าน 2! อุโมงค์อันตราย",
				"ฝ่าดงศัตรูในอุโมงค์แคบ \nและเก็บไอเทมด้วยการตอบคำถามไปจนสุดปลายทาง",
				"เตรียมตัวตอบคำถาม!"
			]
			page_images = [
				preload("res://tutorial/Screenshot 2025-12-09 062222.png"),
				null, # 🟢 แก้ pnull เป็น null
				null  # 🟢 แก้ pnull เป็น null
			]
			page_image_sizes = [
				Vector2(1500, 1500),
				Vector2.ZERO,
				Vector2.ZERO
			]

		2: # === ด่าน 3 ===
			pages = [
				"เข้าสู่ด่าน 3! เขาวงกตปริศนา",
				"หาทางออกจากเขาวงกตที่ซับซ้อน",
				"ระวังศัตรูที่ซ่อนอยู่\nตอบคำถามเพื่อเก็บไอเทมที่มีอยู่ทั่วแมพ"
			]
			page_images = [
				preload("res://tutorial/Screenshot 2025-12-09 062303.png"),
				null,
				null # 🟢 แก้ ืnull เป็น null
			]
			page_image_sizes = [
				Vector2(1500, 1500),
				Vector2.ZERO,
				Vector2.ZERO
			]

		3: # === ด่าน 4 ===
			pages = [
				"ยินดีต้อนรับสู่ด่านสุดท้าย!",
				"ก้าวเดินอย่างระวัง! พื้นบางแผ่นเป็นกับดักที่พร้อมจะร่วงหล่น\nจงเลือกเหยียบให้ถูกทาง",
				"ถ้าคุณผ่านด่านนี้ได้\nคุณคือผู้ชนะที่แท้จริง!"
			]
			page_images = [
				preload("res://tutorial/Screenshot 2025-12-09 063011.png"),
				preload("res://tutorial/Screenshot 2025-12-09 064332.png"),
				null
			]
			page_image_sizes = [
				Vector2(1500, 1500),
				Vector2(1500, 1500),
				Vector2.ZERO
			]
			
		_: # === กรณี Error ===
			pages = ["Error Loading Data"]
			page_images = [null]
			page_image_sizes = [Vector2.ZERO]

# ---------------------------
# SHOW PAGE
# ---------------------------
func show_page(i: int):
	index = i
	
	if index < pages.size():
		_label.text = pages[index]
		
	var current_img = null
	
	if index < page_images.size():
		current_img = page_images[index]

	if current_img != null:
		_image.visible = true
		_image.texture = current_img
		
		if index < page_image_sizes.size():
			var size_setting = page_image_sizes[index]
			
			if size_setting != Vector2.ZERO:
				_image.custom_minimum_size = size_setting
				_image.size = size_setting 
				
				# ==================================================
				# 🟢 สูตรใหม่: วางกึ่งกลางหน้าจอเป๊ะๆ (Center Screen)
				# ==================================================
				var screen_size = get_viewport_rect().size
				
				# หาจุดกึ่งกลางของหน้าจอ
				var center_x = screen_size.x / 2
				var center_y = screen_size.y / 1 
				
				# ปรับเลื่อนแกน Y เล็กน้อย (ถ้าต้องการ)
				# เช่น ถ้าอยากให้รูปลอยขึ้นหนีปุ่มกด ให้ลบค่า Y ออก (เช่น -100)
				# ถ้าอยากให้ลงต่ำ ให้บวกค่า Y
				var offset_y = 300 

				# คำนวณตำแหน่งมุมซ้ายบนของรูป
				var new_x = center_x - (size_setting.x / 2)
				var new_y = (center_y - (size_setting.y / 2)) + offset_y
				
				_image.global_position = Vector2(new_x, new_y)
				# ==================================================
					
	else:
		_image.visible = false
		_image.texture = null

	# 3. จัดการปุ่ม Next / Exit
	if index >= pages.size() - 1:
		_btn_next.visible = false
		_btn_exit.visible = true
	else:
		_btn_next.visible = true
		_btn_exit.visible = false

# ---------------------------
# NEXT PAGE
# ---------------------------
func next_page():
	if index < pages.size() - 1:
		show_page(index + 1)

# ---------------------------
# EXIT TUTORIAL
# ---------------------------
func exit_tutorial():
	emit_signal("tutorial_finished")
	self.visible = false
