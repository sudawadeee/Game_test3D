extends Control

@onready var start_button: Button = $StartButton
@onready var quit_button: Button = $QuitButton

func _ready():
	# ป้องกัน connect ซ้ำ
	if not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)

	if not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	# =========================================================
	# 🟢 1. สั่งให้เกมเข้าโหมด Fullscreen (มือถือจะหมุนจอให้)
	# =========================================================
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# =========================================================
	# 🟢 2. (สำหรับ Web) บังคับ JavaScript ล็อคจอแนวนอน
	# =========================================================
	if OS.has_feature("web"):
		JavaScriptBridge.eval("screen.orientation.lock('landscape')")
	
	# =========================================================
	# 🟢 3. เปลี่ยนฉากไปเริ่มเกม
	# เช็คชื่อไฟล์ให้ดีนะครับ ว่าด่านแรกของคุณชื่อ "Level1.tscn" หรือ "main.tscn"
	# =========================================================
	
	# ถ้าใช้ระบบ Level ที่เราทำกันมา แนะนำให้ชี้ไปที่ Level1 ครับ
	get_tree().change_scene_to_file("res://scenes/main.tscn") 
	
	# หรือถ้าด่านแรกของคุณชื่อ main.tscn ก็ใช้บรรทัดนี้แทน:
	# get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
