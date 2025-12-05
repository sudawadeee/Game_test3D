extends Node3D

@onready var area: Area3D = $Area3D

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)


func _on_area_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	# เงื่อนไขตามโจทย์:
	# - ถ้ายังตอบไม่ครบ 10 ข้อ → ไม่ทำอะไร
	# - ถ้าจบเกมไปแล้ว (finished = true) → ไม่ทำอะไร
	if not Game.can_finish():
		return

	# ผ่านเงื่อนไข = ตอบครบแล้ว และเกมยังไม่จบ
	var _is_win := Game.finish_level()
