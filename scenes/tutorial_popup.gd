# tutorial.gd
extends Control

# ---------------------------
# ข้อความแต่ละหน้า (เรียบเรียงใหม่)
# ---------------------------
var pages := [
	"ยินดีต้อนรับสู่เกม!\nภารกิจของคุณคือการตอบคำถามให้ถูกต้อง\nและหาธงเพื่อผ่านด่าน\n(กด ESC เพื่อเปิดใช้งานเมาส์)",
	
	"คุณจะพบคำถามทั้งหมด 10 ข้อ\nพยายามตอบให้ถูกอย่างน้อย 7 ข้อ\nเพื่อเก็บไอเทมและชนะเกม",

	"การควบคุมพื้นฐาน:\nกดปุ่ม W A S D = เดินหน้า ซ้าย หลัง ขวา",

	"การกระโดด:\n Spacebar = กระโดดปกติ\n กด Spacebar 2 ครั้ง = กระโดดสูง\n(Spacebar คือปุ่มยาวด้านล่างของคีย์บอร์ด)",

	"ศัตรู:\nอย่าเข้าใกล้ด้านข้างของมัน!\nให้กระโดดเหยียบหัวเพื่อกำจัดมัน",

	"พร้อมแล้วใช่ไหม?\nไปผจญภัยกันเลย!"
]

# ---------------------------
# รูปภาพสำหรับแต่ละหน้า
# จำนวนต้องเท่ากับ pages
# ---------------------------
var page_images := [
	preload("res://tutorial/welcome.png"),
	preload("res://tutorial/quetion.png"),
	preload("res://tutorial/wasd-keys-_wasdkey.webp"),
	preload("res://tutorial/spacebar.jpg"),
	preload("res://tutorial/Screenshot 2025-11-24 235102.png")
]

var index := 0

@onready var _label: Label = $Panel/data
@onready var _image: TextureRect = $Panel/ImageRect
@onready var _btn_next: Button = $Panel/BtnNext
@onready var _btn_exit: Button = $Panel/BtnExit

signal tutorial_finished


# ---------------------------
# INITIALIZE
# ---------------------------
func _ready() -> void:
	show_page(0)
	_btn_next.pressed.connect(next_page)
	_btn_exit.pressed.connect(exit_tutorial)


# ---------------------------
# SHOW PAGE
# ---------------------------
func show_page(i: int):
	index = i

	# ข้อความ
	_label.text = pages[index]

	# รูปภาพ
	if index < page_images.size():
		_image.texture = page_images[index]
	else:
		_image.texture = null

	# ปุ่ม
	if index == pages.size() - 1:
		_btn_next.visible = false
		_btn_exit.visible = true
	else:
		_btn_next.visible = true
		_btn_exit.visible = false


# ---------------------------
# NEXT PAGE
# ---------------------------
func next_page():
	if index < pages.size() - 1:
		show_page(index + 1)


# ---------------------------
# EXIT TUTORIAL
# ---------------------------
func exit_tutorial():
	emit_signal("tutorial_finished")
	self.visible = false
