extends Control

var dragging := false
var last_pos := Vector2.ZERO
signal look_input(delta: Vector2)

func _input(event):
	# Touch begin
	if event is InputEventScreenTouch:
		if event.pressed and _inside(event.position):
			dragging = true
			last_pos = event.position
		elif dragging and !event.pressed:
			dragging = false

	# Touch drag
	if event is InputEventScreenDrag and dragging:
		var delta = event.position - last_pos
		last_pos = event.position
		emit_signal("look_input", delta)

	# Mouse begin (PC)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _inside(event.position):
			dragging = true
			last_pos = event.position
		elif !event.pressed:
			dragging = false

	# Mouse drag (PC)
	if event is InputEventMouseMotion and dragging:
		var delta = event.relative
		emit_signal("look_input", delta)


func _inside(screen_pos: Vector2) -> bool:
	var rect = Rect2(get_screen_position(), size)
	return rect.has_point(screen_pos)
