extends Area3D

@export var checkpoint_color_default: Color = Color(1, 1, 0) # เหลือง
@export var checkpoint_color_active: Color = Color(0, 1, 0)  # เขียว
var activated := false

@onready var sound_checkpoint: AudioStreamPlayer3D = $SoundCheckpoint

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# ตั้งสีเริ่มต้น
	if $MeshInstance3D.material_override == null:
		$MeshInstance3D.material_override = StandardMaterial3D.new()
	$MeshInstance3D.material_override.albedo_color = checkpoint_color_default

func _on_body_entered(body):
	if body.is_in_group("player") and not activated:
		activated = true
		body.set_checkpoint(global_transform.origin)
		$MeshInstance3D.material_override.albedo_color = checkpoint_color_active
		
		sound_checkpoint.play() # ✅ เล่นเสียงตอนเปิดใช้งานครั้งแรก
		
		print("✅ Checkpoint activated at:", global_transform.origin)
