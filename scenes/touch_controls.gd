extends Control

@onready var left_joy: Control = $LeftJoy
@onready var left_inner: Control = $LeftJoy/Inner

var left_radius: float
var is_dragging := false
var touch_id := -1
var left_output := Vector2.ZERO


func _ready():
	await get_tree().process_frame
	left_radius = left_joy.size.x * 0.5
	_reset_inner()

	# Control ต้องรับ input
	mouse_filter = Control.MOUSE_FILTER_STOP
	left_joy.mouse_filter = Control.MOUSE_FILTER_STOP
	left_inner.mouse_filter = Control.MOUSE_FILTER_STOP


# ================================================
# INPUT HANDLER (มือถือ + คอม)
# ================================================
func _input(event):

	# --------------------
	# TOUCH START (มือถือ)
	# --------------------
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_inside(event.position):
				is_dragging = true
				touch_id = event.index
				_update_joy(event.position)
		else:
			if event.index == touch_id:
				_reset_joy()

	# --------------------
	# TOUCH DRAG (มือถือ)
	# --------------------
	elif event is InputEventScreenDrag:
		if is_dragging and event.index == touch_id:
			_update_joy(event.position)

	# --------------------
	# MOUSE DOWN (คอม)
	# --------------------
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _touch_inside(event.position):
					is_dragging = true
					touch_id = 999  # mouse id
					_update_joy(event.position)
			else:
				if touch_id == 999:
					_reset_joy()

	# --------------------
	# MOUSE MOVE (คอม)
	# --------------------
	elif event is InputEventMouseMotion:
		if is_dragging and touch_id == 999:
			_update_joy(event.position)



# ================================================
# CHECK TOUCH/MOUSE INSIDE JOYSTICK
# ================================================
func _touch_inside(screen_pos: Vector2) -> bool:
	var pos = left_joy.get_screen_position()
	var rect = Rect2(pos, left_joy.size)
	return rect.has_point(screen_pos)


# ================================================
# UPDATE JOY POSITION
# ================================================
func _update_joy(screen_pos: Vector2):
	var pos = left_joy.get_screen_position()
	var local = screen_pos - pos

	var center = left_joy.size * 0.5
	var offset = local - center

	if offset.length() > left_radius:
		offset = offset.normalized() * left_radius

	left_inner.position = center - left_inner.size * 0.5 + offset
	left_output = offset / left_radius


# ================================================
# RESET JOYSTICK
# ================================================
func _reset_joy():
	is_dragging = false
	touch_id = -1
	left_output = Vector2.ZERO
	_reset_inner()


func _reset_inner():
	left_inner.position = (left_joy.size - left_inner.size) * 0.5
