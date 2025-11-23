# Main.gd
extends Node3D

@export var level_time: float = 200  
@export var warning_time: float = 15

@onready var _timer: Timer = $Timer
@onready var _time_label: Label = get_node_or_null("%TimeLabel")
@onready var _message_label: Label = get_node_or_null("%MessageLabel")

@onready var bgm: AudioStreamPlayer = $BGM
@onready var tutorial_popup: Control = $CanvasLayer2/TutorialPopup

var _message_shown := false

# ---------------------------
# Mouse Control
# ---------------------------
func lock_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func free_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ready() -> void:
	_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	# เริ่ม BGM
	if not bgm.playing:
		bgm.play()

	# แสดง Tutorial ก่อนเริ่มเกม
	if tutorial_popup:
		tutorial_popup.visible = true

		if not tutorial_popup.tutorial_finished.is_connected(_on_tutorial_finished):
			tutorial_popup.tutorial_finished.connect(_on_tutorial_finished)

		free_mouse()
	else:
		push_warning("⚠ TutorialPopup ไม่พบใน Scene!")

	# ตั้ง Timer แต่ยังไม่เริ่มทำงาน
	_timer.one_shot = true
	_timer.wait_time = level_time

	# ซ่อนข้อความเตือน
	if _message_label:
		_message_label.visible = false


# ---------------------------
# Tutorial ปิด → เริ่มเกมจริง
# ---------------------------
func _on_tutorial_finished():
	# รีเซ็ตคะแนนทุกอย่างก่อนเริ่มเล่น
	Game.begin_level()

	if not _timer.timeout.is_connected(_on_time_up):
		_timer.timeout.connect(_on_time_up)

	_timer.start()
	lock_mouse()


# ---------------------------
# Process
# ---------------------------
func _process(delta: float) -> void:
	# ESC → ปล่อยเมาส์ออกมา
	if Input.is_action_just_pressed("ui_cancel"):
		free_mouse()

	# อัปเดตเวลาบน UI
	if _timer and not _timer.is_stopped() and _time_label:
		_time_label.text = str(int(ceil(_timer.time_left)))

		# ใกล้หมดเวลาแล้ว
		if not _message_shown and _timer.time_left <= warning_time:
			_show_message("Find the flag to win!")  # ถ้าไม่อยากมี text ในโค้ด เดี๋ยวคุยต่อได้


# ---------------------------
# Show temporary message
# ---------------------------
func _show_message(text: String) -> void:
	_message_shown = true

	if _message_label:
		_message_label.text = text
		_message_label.visible = true

		await get_tree().create_timer(5.0).timeout
		_message_label.visible = false
		_message_shown = false 


# ---------------------------
# When time is up (Loss)
# ---------------------------
func _on_time_up() -> void:
	print("⏲ Time up!")

	# หยุดเพลงถ้าต้องการ
	if bgm.playing:
		bgm.stop()

	# หมดเวลา = แพ้แน่นอน (ไม่สนว่าจะตอบครบหรือยัง)
	Game.force_lose_by_timeout()
