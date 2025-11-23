# res://scripts/CoinCounter.gd
extends Node

func _ready() -> void:
	await get_tree().process_frame  # รอ 1 เฟรมให้เหรียญเข้ากลุ่มให้ครบ
	var total := get_tree().get_nodes_in_group("coin").size()
