extends Area3D

class_name RaceMilestoneTrigger

@export var start_line : bool = false
@export var next_milestone : RaceMilestoneTrigger

@export var audio : AudioStreamPlayer3D



func _on_body_entered(body):
	print("!!! Milestone entered: ", name)
	if SphereCar.instance == null:
		print("!!! no spherecar!")
		return
		
	if GameController.instance == null:
		print("!!! no gamecontroller!")
		return
	
	# only care abt the car	
	if (body != SphereCar.instance.ball):
		print("!!! skipping, not the car!")
		return
	
	if (GameController.instance.next_milestone != self):
		print("!!!wrong milestone. next one is")
		return
		
	print("!!! Milestone reached: ", name)
	
	if (audio != null):
		audio.play()
	
	GameController.instance.next_milestone = next_milestone
	if (start_line):
		GameController.instance.add_lap()
	
