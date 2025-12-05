extends TextureButton
signal jump_pressed

func _ready():
	pressed.connect(func():
		emit_signal("jump_pressed")
	)
