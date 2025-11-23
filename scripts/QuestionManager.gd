extends Node

var questions: Array = []          # คำถามทั้งหมด
var unused_questions: Array = []    # คำถามที่ยังไม่ถูกใช้

func _ready():
	load_questions()
	reset_unused()

func load_questions():
	var file := FileAccess.open("res://scripts/questions.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_ARRAY:
			questions = data
		else:
			push_error("❌ รูปแบบ JSON ไม่ถูกต้อง")
	else:
		push_error("❌ โหลดไฟล์ JSON ไม่ได้")

func reset_unused():
	# ก็อปคำถามทั้งหมดมาทำชุดใหม่
	unused_questions = questions.duplicate()

func get_random_question() -> Dictionary:
	if unused_questions.is_empty():
		# ถ้าถามหมดแล้ว → reset ใหม่
		reset_unused()

	# จิ้มคำถามแบบไม่ซ้ำแล้วลบออก
	var q = unused_questions.pick_random()
	unused_questions.erase(q)

	return q
