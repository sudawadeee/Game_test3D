# WinPopup.gd 
extends Control

@onready var title_lose: Label = $VBoxContainer/TitleLabel2
@onready var title_win:  Label = $VBoxContainer/TitleLabel

@onready var correct_value_label: Label  = $VBoxContainer/HBoxCorrect/CorrectValue
@onready var total_value_label:   Label  = $VBoxContainer/HBoxTotal/TotalValue
@onready var percent_value_label: Label  = $VBoxContainer/HBoxPercent/PercentValue

@onready var restart_btn: Button = $VBoxContainer/RestartButton
@onready var quit_btn:    Button = $VBoxContainer/QuitButton

# ปุ่ม Next Level (ใช้ %)
@onready var next_level: Button = %NextLevelButton

# เสียง
@onready var win_sound:  AudioStreamPlayer3D = $WinSound
@onready var lose_sound: AudioStreamPlayer3D = $LoseSound

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	restart_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	quit_btn.process_mode    = Node.PROCESS_MODE_WHEN_PAUSED
	next_level.process_mode  = Node.PROCESS_MODE_WHEN_PAUSED

	# เชื่อมต่อปุ่ม
	if not restart_btn.pressed.is_connected(_on_restart_pressed):
		restart_btn.pressed.connect(_on_restart_pressed)
	if not quit_btn.pressed.is_connected(_on_quit_pressed):
		quit_btn.pressed.connect(_on_quit_pressed)
	if not next_level.pressed.is_connected(_on_next_level_pressed):
		next_level.pressed.connect(_on_next_level_pressed)

	if not Game.win.is_connected(_on_game_win):
		Game.win.connect(_on_game_win)
	if not Game.lose.is_connected(_on_game_lose):
		Game.lose.connect(_on_game_lose)

func _on_game_win(correct: int, total: int) -> void:
	_show_result(true, correct, total)

func _on_game_lose(correct: int, total: int) -> void:
	_show_result(false, correct, total)

func _show_result(is_win: bool, correct: int, total: int) -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# 1. รีเซ็ต: ซ่อนของเก่าก่อน
	title_win.visible = false
	title_lose.visible = false
	next_level.visible = false
	restart_btn.visible = false
	
	# 🔴 สั่งให้ปุ่มออกเกมแสดงเสมอ (ไม่ว่าจะแพ้หรือชนะ)
	quit_btn.visible = true

	_stop_sounds()

	if is_win:
		# ✅ กรณีชนะ
		title_win.visible = true
		win_sound.play()
		
		# แสดงปุ่มไปต่อ
		next_level.visible = true
		next_level.grab_focus()

		if Game.current_level_index < Game.levels.size() - 1:
			next_level.text = "ด่านต่อไป"
		else:
			next_level.text = "เล่นอีกครั้ง"
			
	else:
		# ❌ กรณีแพ้
		title_lose.visible = true
		lose_sound.play()
		
		# แสดงปุ่มเริ่มใหม่
		restart_btn.visible = true 
		restart_btn.grab_focus()

	# แสดงคะแนน
	correct_value_label.text = str(correct)
	total_value_label.text   = str(total)

	var percent := 0
	if total > 0:
		percent = int(float(correct) / float(total) * 100)
	percent_value_label.text = str(percent)

	await get_tree().process_frame
	get_tree().paused = true

func _on_next_level_pressed() -> void:
	_stop_sounds()
	get_tree().paused = false 
	
	if Game.current_level_index >= Game.levels.size() - 1:
		Game.go_to_level(0) # กลับไปด่าน 1
	else:
		Game.next_level()

func _on_restart_pressed() -> void:
	_stop_sounds()
	get_tree().paused = false
	if Game.has_method("restart_level"):
		Game.restart_level()
	else:
		get_tree().reload_current_scene()

# 🔴 ฟังก์ชันปุ่มออกเกม
func _on_quit_pressed() -> void:
	_stop_sounds()
	get_tree().paused = false
	get_tree().quit() # ปิดเกม

func _stop_sounds():
	if win_sound.playing: win_sound.stop()
	if lose_sound.playing: lose_sound.stop()
