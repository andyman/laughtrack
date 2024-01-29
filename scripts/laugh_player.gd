extends Node

class_name LaughPlayer

@export var rb : RigidBody3D
@export var players : Array[AudioStreamPlayer] = []

@export var clips : Array[AudioStream] = []

var nextPlayerIndex : int = 0
var time_to_laugh : float = 3.0

func _ready():
	pass
	
func _process(delta):
	var speed : float = rb.linear_velocity.length()	
	#print("Speed: ", speed)
	time_to_laugh -= delta * (1.0 + speed / 50.0)
	if (time_to_laugh <= 0):
		time_to_laugh = randf_range(4.0, 5.0)
		var player : AudioStreamPlayer = players[nextPlayerIndex]
		nextPlayerIndex = (nextPlayerIndex+1) % players.size()
		
		player.stream = clips.pick_random()
		player.pitch_scale = randf_range(0.9, 1.1)
		player.volume_db = lerp(-24.0, -12.0, clampf(speed / 50.0, 0.0, 1.0))
		player.play()
		
	
