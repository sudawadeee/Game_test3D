#Game.gd
extends Node

# ==========================================================
# SIGNALS: ส่งสัญญาณบอกเกมว่า ชนะ หรือ แพ้
# ==========================================================
signal win(correct: int, total: int)
signal lose(correct: int, total: int)

# ==========================================================
# LEVEL SETTINGS: รายชื่อด่านทั้งหมด
# 🔴 สำคัญ: เช็คชื่อไฟล์และ Path ให้ตรงกับที่คุณสร้างจริง
# ==========================================================
var levels: Array = [
	"res://scenes/main.tscn",
	"res://scenes/Level2.tscn",
	"res://scenes/Level3.tscn",
	"res://scenes/Level4.tscn"
]

# ตัวแปรเก็บความคืบหน้า
var current_level_index: int = 0
var unlocked_level_index: int = 0

# ==========================================================
# GAMEPLAY VARIABLES: ตัวแปรระหว่างเล่น
# ==========================================================
var total_items := 5        # จำนวนข้อที่ต้องตอบให้ครบ
var answered_count := 0      # ตอบไปแล้วกี่ข้อ
var correct_count := 0       # ตอบถูกกี่ข้อ
var wrong_count := 0         # ตอบผิดกี่ข้อ

@export var pass_ratio := 0.8  # เกณฑ์ผ่าน (0.7 = 70% หรือ 7 ข้อ)
var finished: bool = false     # กันจบเกมซ้ำซ้อน

# ==========================================================
# READY & SAVE SYSTEM
# ==========================================================
func _ready():
	load_game() # โหลดเซฟเมื่อเปิดเกมครั้งแรก

func save_game():
	var config = ConfigFile.new()
	# บันทึกด่านล่าสุดที่ปลดล็อก
	config.set_value("Progress", "unlocked_level", unlocked_level_index)
	config.save("user://savegame.cfg")
	print("💾 Game Saved! Max Level: ", unlocked_level_index)

func load_game():
	var config = ConfigFile.new()
	var err = config.load("user://savegame.cfg")
	if err == OK:
		unlocked_level_index = config.get_value("Progress", "unlocked_level", 0)
		print("📂 Game Loaded. Max Level: ", unlocked_level_index)

# ==========================================================
# LEVEL NAVIGATION: เปลี่ยนด่าน
# ==========================================================
func go_to_level(index: int):
	# ตรวจสอบว่ามีด่านนี้อยู่จริงไหม
	if index < levels.size():
		current_level_index = index
		# เปลี่ยน Scene
		get_tree().change_scene_to_file(levels[index])
		# รีเซ็ตค่าคะแนนเพื่อเริ่มเล่นใหม่
		begin_level()
		print("🚀 Loading Level: ", index + 1)
	else:
		# ถ้าเกินด่านสุดท้าย (จบเกม)
		print("🎉 Congratulation! You beat the game.")
		# สามารถสั่งให้กลับหน้าเมนูหลัก หรือออกเกมได้ที่นี่
		# get_tree().quit() หรือ change_scene_to_file("res://scenes/MainMenu.tscn")

func next_level():
	var next_idx = current_level_index + 1
	
	# ถ้าด่านถัดไป เป็นด่านที่เราเพิ่งเล่นถึงครั้งแรก ให้ปลดล็อกและบันทึก
	if next_idx > unlocked_level_index:
		unlocked_level_index = next_idx
		save_game()
	
	# ไปด่านถัดไป
	go_to_level(next_idx)

func restart_level():
	go_to_level(current_level_index)

# ==========================================================
# LOGIC: ระบบนับคะแนน
# ==========================================================
func begin_level() -> void:
	answered_count = 0
	correct_count = 0
	wrong_count = 0
	finished = false
	# คลาย Pause (สำคัญมาก เผื่อกด Restart แล้วเกมยังหยุดอยู่)
	get_tree().paused = false

func add_answer(correct: bool) -> void:
	if finished:
		return

	answered_count += 1
	if correct:
		correct_count += 1
	else:
		wrong_count += 1
	
	print("Progress: ", answered_count, "/", total_items, " | Correct: ", correct_count)

# เช็คว่าตอบครบหรือยัง (ใช้สำหรับประตูชัยเช็คว่าให้ผ่านไหม)
func can_finish() -> bool:
	return (not finished) and answered_count >= total_items

# สรุปผลตอนจบด่าน
func finish_level() -> bool:
	if finished:
		return false
	if answered_count < total_items:
		return false # ยังตอบไม่ครบ ห้ามจบ

	finished = true

	# คำนวณเปอร์เซ็นต์
	var percent := float(correct_count) / float(total_items)

	if percent >= pass_ratio:
		# ผ่าน!
		emit_win()
		return true
	else:
		# ไม่ผ่าน!
		emit_lose()
		return false

# กรณีหมดเวลา (แพ้ทันที)
func force_lose_by_timeout() -> void:
	if finished:
		return
	finished = true
	emit_lose()

# ==========================================================
# HELPER: ส่งสัญญาณ
# ==========================================================
func emit_win() -> void:
	print("🏆 WIN!")
	win.emit(correct_count, total_items)

func emit_lose() -> void:
	print("💀 LOSE!")
	lose.emit(correct_count, total_items)
