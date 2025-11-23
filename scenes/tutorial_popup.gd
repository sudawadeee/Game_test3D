extends Control

var pages := [
	"ยินดีต้อนรับสู่เกม!\nในเกมนี้คุณต้องหาธงให้เจอ",
	"ใช้ W A S D เพื่อควบคุมการเดิน",
	"ระวังศัตรูและอุปสรรค",
	"พร้อมแล้ว เริ่มเกม!"
]

var index := 0

@onready var _label := $Panel/data
@onready var _btn_next := $Panel/BtnNext
@onready var _btn_exit := $Panel/BtnExit

signal tutorial_finished

func _ready() -> void:
	show_page(0)
	_btn_next.pressed.connect(next_page)
	_btn_exit.pressed.connect(exit_tutorial)

func show_page(i: int):
	index = i
	_label.text = pages[index]

	if index == pages.size() - 1:
		_btn_next.visible = false
		_btn_exit.visible = true
	else:
		_btn_next.visible = true
		_btn_exit.visible = false

func next_page():
	if index < pages.size() - 1:
		show_page(index + 1)

func exit_tutorial():
	emit_signal("tutorial_finished")
	self.visible = false
