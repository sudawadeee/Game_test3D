# game_over_ui.gd (ติดกับ Node GameOverUI)
extends Control

@onready var btn_retry: Button = %Retry
@onready var btn_quit: Button = %Quit

func _ready():
	visible = false
	# สำคัญ: ต้องตั้ง PROCESS_MODE_WHEN_PAUSED เพื่อให้ปุ่มยังใช้งานได้เมื่อเกมหยุด
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED 
	btn_retry.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	btn_quit.process_mode  = Node.PROCESS_MODE_WHEN_PAUSED

	if not btn_retry.pressed.is_connected(_on_restart_pressed):
		btn_retry.pressed.connect(_on_restart_pressed)
	if not btn_quit.pressed.is_connected(_on_quit_pressed):
		btn_quit.pressed.connect(_on_quit_pressed)

func show_game_over():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# ใช้ await เพื่อรอให้เฟรมถัดไปทำงานก่อนสั่งหยุดเกม
	await get_tree().process_frame
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()
