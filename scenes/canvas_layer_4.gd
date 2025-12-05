extends CanvasLayer

@onready var left_joy  = $LeftJoy
@onready var right_joy = $RightJoy
@onready var jump_btn  = $JumpBtn

var move_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.ZERO
var jump_pressed: bool = false

func _process(delta):
	move_vector = left_joy.get_value()          # vector -1..1
	aim_vector  = right_joy.get_value()
	jump_pressed = jump_btn.is_pressed()

func get_movement() -> Vector2:
	return move_vector

func get_aim() -> Vector2:
	return aim_vector

func is_jump_pressed() -> bool:
	return jump_pressed
