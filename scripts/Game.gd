extends Node

signal win(correct: int, total: int)
signal lose(correct: int, total: int)

var total_items := 10
var answered_count := 0
var correct_count := 0
var wrong_count := 0

@export var pass_ratio := 0.7
var finished: bool = false      # กันจบซ้ำ


func begin_level() -> void:
	answered_count = 0
	correct_count = 0
	wrong_count = 0
	finished = false


func add_answer(correct: bool) -> void:
	if finished:
		return

	answered_count += 1
	if correct:
		correct_count += 1
	else:
		wrong_count += 1


func can_finish() -> bool:
	return (not finished) and answered_count >= total_items


func finish_level() -> bool:
	if finished:
		return false
	if answered_count < total_items:
		return false

	finished = true

	var percent := float(correct_count) / float(total_items)

	if percent >= pass_ratio:
		emit_win()
		return true
	else:
		emit_lose()
		return false


func force_lose_by_timeout() -> void:
	if finished:
		return
	finished = true
	emit_lose()


func emit_win() -> void:
	win.emit(correct_count, total_items)

func emit_lose() -> void:
	lose.emit(correct_count, total_items)
