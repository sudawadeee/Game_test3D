extends Control

signal answered(correct: bool)

@onready var question_label: Label = %QuestionLabel
@onready var btn_a: Button = %BtnA
@onready var btn_b: Button = %BtnB
@onready var btn_c: Button = %BtnC
@onready var btn_d: Button = %BtnD
@onready var panel: Control = $Panel

var correct_answer := ""

func _ready():
	visible = false

	# สำคัญที่สุด → UI ต้องทำงานตอน paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# รับคลิกเสมอ
	mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# UI อยู่บนสุด
	top_level = true
	z_index = 99999

	# Connect ปุ่ม
	btn_a.pressed.connect(_on_BtnA_pressed)
	btn_b.pressed.connect(_on_BtnB_pressed)
	btn_c.pressed.connect(_on_BtnC_pressed)
	btn_d.pressed.connect(_on_BtnD_pressed)


func ask_question(q: String, choices: Array, correct: String):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	print("\n=== แสดงคำถามใหม่ ===")
	print("คำถาม:", q)
	print("ตัวเลือก:", choices)
	print("เฉลย:", correct)

	question_label.text = q
	correct_answer = correct

	btn_a.text = choices[0]
	btn_b.text = choices[1]
	btn_c.text = choices[2]
	btn_d.text = choices[3]

	get_tree().paused = true
	visible = true


func _on_BtnA_pressed():
	print("BTN A PRESSED!")
	_check(btn_a.text)

func _on_BtnB_pressed():
	_check(btn_b.text)

func _on_BtnC_pressed():
	_check(btn_c.text)

func _on_BtnD_pressed():
	_check(btn_d.text)


func _check(choice_text: String):
	var selected := choice_text.substr(0, 1)
	var is_correct := (selected == correct_answer)

	visible = false

	# คืน mouse ให้ player ควบคุม
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# คืนเกม
	get_tree().paused = false  

	emit_signal("answered", is_correct)
