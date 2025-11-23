extends Node3D

var anims = ["Armature|Idle", "Armature|Jump"]
var index := 0

func _ready() -> void:
	play_next_animation()

func play_next_animation():
	var anim_name = anims[index]
	index = (index + 1) % anims.size()

	$AnimationPlayer.play(anim_name)
	var length = $AnimationPlayer.get_animation(anim_name).length

	await get_tree().create_timer(length).timeout
	play_next_animation()
