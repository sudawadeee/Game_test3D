# FlagTrigger.gd (แนบกับ Area3D)
extends Area3D

signal player_won

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody3D:
		player_won.emit()
