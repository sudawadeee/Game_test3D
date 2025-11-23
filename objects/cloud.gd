extends Node3D

var time = 0.0

var random_number = RandomNumberGenerator.new()

var random_velocity:float
var random_time:float

func _ready():
	
	random_velocity = random_number.randf_range(0.1, 1.5)
	random_time = random_number.randf_range(0.1, 1.5)

func _process(delta):
	
	position.y += (cos(time * random_time) * random_velocity) * delta # Sine movement
	
	time += delta
