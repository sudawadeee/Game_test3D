#LookArea
extends Control

signal look_input(delta: Vector2)

var look_touch_id: int = -1
var last_pos: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:

	# ===============================
	# TOUCH INPUT
	# ===============================
	if event is InputEventScreenTouch:
		if event.pressed:
			if _inside(event.position):
				look_touch_id = event.index
				last_pos = event.position
		else:
			if event.index == look_touch_id:
				look_touch_id = -1

	elif event is InputEventScreenDrag:
		if event.index == look_touch_id:
			var delta: Vector2 = event.position - last_pos
			last_pos = event.position
			emit_signal("look_input", delta)


	# ===============================
	# MOUSE INPUT (PC)
	# ===============================
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _inside(event.position):
				look_touch_id = 9999
				last_pos = event.position
			elif !event.pressed and look_touch_id == 9999:
				look_touch_id = -1

	elif event is InputEventMouseMotion:
		if look_touch_id == 9999:
			var delta: Vector2 = event.relative
			emit_signal("look_input", delta)


func _inside(screen_pos: Vector2) -> bool:
	var rect := Rect2(get_global_position(), size)
	return rect.has_point(screen_pos)
