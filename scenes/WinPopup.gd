# WinPopup.gd 
extends Control

@onready var title_lose: Label = $VBoxContainer/TitleLabel2
@onready var title_win:  Label = $VBoxContainer/TitleLabel

@onready var correct_value_label: Label  = $VBoxContainer/HBoxCorrect/CorrectValue
@onready var total_value_label:   Label  = $VBoxContainer/HBoxTotal/TotalValue
@onready var percent_value_label: Label  = $VBoxContainer/HBoxPercent/PercentValue

@onready var restart_btn: Button = $VBoxContainer/RestartButton
@onready var quit_btn:    Button = $VBoxContainer/QuitButton

# เสียงชนะ/แพ้
@onready var win_sound:  AudioStreamPlayer3D = $WinSound
@onready var lose_sound: AudioStreamPlayer3D = $LoseSound


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	restart_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	quit_btn.process_mode    = Node.PROCESS_MODE_WHEN_PAUSED

	if not restart_btn.pressed.is_connected(_on_restart_pressed):
		restart_btn.pressed.connect(_on_restart_pressed)
	if not quit_btn.pressed.is_connected(_on_quit_pressed):
		quit_btn.pressed.connect(_on_quit_pressed)

	# Game ต้องเป็น Autoload ชื่อ Game
	if not Game.win.is_connected(_on_game_win):
		Game.win.connect(_on_game_win)
	if not Game.lose.is_connected(_on_game_lose):
		Game.lose.connect(_on_game_lose)


func _on_game_win(correct: int, total: int) -> void:
	_show_result(true, correct, total)

func _on_game_lose(correct: int, total: int) -> void:
	_show_result(false, correct, total)


func show_result_screen(is_win: bool, correct: int, total: int) -> void:
	_show_result(is_win, correct, total)


func _show_result(is_win: bool, correct: int, total: int) -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# ซ่อนหัวข้อทั้งสองก่อน
	title_win.visible = false
	title_lose.visible = false

	# หยุดเสียงเดิมกันค้าง
	if win_sound.playing:
		win_sound.stop()
	if lose_sound.playing:
		lose_sound.stop()

	if is_win:
		title_win.visible = true
		win_sound.play()   # 🔊 เล่นเสียงชนะ
	else:
		title_lose.visible = true
		lose_sound.play()  # 🔊 เล่นเสียงแพ้

	# ตัวเลข
	correct_value_label.text = str(correct)
	total_value_label.text   = str(total)

	var percent := 0
	if total > 0:
		percent = int(float(correct) / float(total) * 100)
	percent_value_label.text = str(percent)

	await get_tree().process_frame
	get_tree().paused = true
	restart_btn.grab_focus()


func _on_restart_pressed() -> void:
	# กันเสียงลากไปฉากใหม่
	if win_sound.playing:
		win_sound.stop()
	if lose_sound.playing:
		lose_sound.stop()

	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	if win_sound.playing:
		win_sound.stop()
	if lose_sound.playing:
		lose_sound.stop()

	get_tree().paused = false
	get_tree().quit()
