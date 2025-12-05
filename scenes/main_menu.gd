extends Control

@onready var start_button: Button = $StartButton
@onready var quit_button: Button = $QuitButton   # ← แก้ชื่อให้ตรง

func _ready():
	# ป้องกัน connect ซ้ำ
	if not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)

	if not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
