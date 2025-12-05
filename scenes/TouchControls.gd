extends CanvasLayer

@onready var left_joy  = $LeftJoy
@onready var right_joy = $RightJoy

var move_input: Vector2 = Vector2.ZERO
var look_input: Vector2 = Vector2.ZERO

func _ready():
	left_joy.analogic_change.connect(_on_left_change)
	right_joy.analogic_change.connect(_on_right_change)

func _on_left_change(v: Vector2):
	move_input = v   # เดิน

func _on_right_change(v: Vector2):
	look_input = v   # หมุนกล้อง

func get_move_vector() -> Vector2:
	return move_input

func get_look_vector() -> Vector2:
	return look_input
