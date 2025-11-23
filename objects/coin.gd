extends Area3D

var grabbed := false

@onready var popup := %QuizPopup


func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	print("DEBUG: player touched coin")

	if grabbed: return
	if not body.is_in_group("Player"): return

	grabbed = true

	monitoring = false
	collision_layer = 0
	collision_mask = 0

	if popup == null:
		print("❌ ERROR: QuizPopup not found")
		return

	var q := QuestionManager.get_random_question()
	if q.is_empty():
		queue_free()
		return

	# ป้องกันเชื่อมซ้ำ → ล้างการเชื่อมทั้งหมดก่อน
	for c in popup.answered.get_connections():
		popup.answered.disconnect(c.callable)

	# แล้วค่อย connect ใหม่
	popup.answered.connect(_on_answered.bind(body, self))

	# แสดงคำถามหลัง physics frame
	call_deferred("_ask", popup, q)


func _ask(popup, q: Dictionary):
	popup.ask_question(q["question"], q["choices"], q["answer"])


func _on_answered(correct: bool, body, coin):
	print("DEBUG: _on_answered called. correct =", correct)
	# เพิ่มแต้ม
	Game.add_answer(correct)

	if correct:
		Audio.play("res://sounds/coin.ogg")

		if body.has_method("collect_coin"):
			body.collect_coin()

	# ลบโมเดลไอเทม (Peppermint candy)
	var peppermint = coin.find_child("Peppermint_candy", true, false)
	if peppermint:
		peppermint.queue_free()
	else:
		print("⚠ Peppermint_candy not found!")

	# ลบ coin
	coin.queue_free()
	# คืนการควบคุมเมาส์
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
