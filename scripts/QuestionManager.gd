#QuestionManager.gd
extends Node

# เปลี่ยนจาก Array เป็น Dictionary เพื่อเก็บข้อมูลทุกด่าน
var all_data: Dictionary = {}    
var current_questions: Array = [] # เก็บเฉพาะคำถามของด่านปัจจุบันที่เลือกมาเล่น
var unused_questions: Array = []

func _ready():
	load_questions_file()

func load_questions_file():
	var file := FileAccess.open("res://scripts/questions.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		
		# 🔴 จุดที่แก้: เช็คว่าเป็น Dictionary แทน Array
		if typeof(data) == TYPE_DICTIONARY:
			all_data = data
			print("✅ Loaded Question Data Successfully")
		else:
			push_error("❌ รูปแบบ JSON ไม่ถูกต้อง (ต้องเป็น Dictionary {level1: [...], ...})")
	else:
		push_error("❌ โหลดไฟล์ JSON ไม่ได้")

# ฟังก์ชันใหม่: เรียกใช้จาก Main.gd เพื่อบอกว่าตอนนี้อยู่ด่านไหน
func set_level_data(level_id: String):
	if all_data.has(level_id):
		current_questions = all_data[level_id]
		reset_unused()
		print("✅ Set questions for: ", level_id)
	else:
		push_error("❌ Level ID not found in JSON: " + level_id)
		# กัน Error ใส่คำถามปลอมๆ ไปก่อนถ้าหาไม่เจอ
		current_questions = [{"question": "Error", "choices": ["A", "B", "C", "D"], "answer": "A"}]
		reset_unused()

func reset_unused():
	unused_questions = current_questions.duplicate()

func get_random_question() -> Dictionary:
	if unused_questions.is_empty():
		reset_unused()
	
	if unused_questions.is_empty():
		return {"question": "Error", "choices": ["A", "B", "C", "D"], "answer": "A"}

	var q = unused_questions.pick_random()
	unused_questions.erase(q)
	return q
