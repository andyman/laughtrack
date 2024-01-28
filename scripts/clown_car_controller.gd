extends VehicleBody3D
class_name ClownCarController

@export var engine_acceleration : float = 200.0
@export var steer_strength : float = 0.4


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta:float):
		steering = Input.get_axis("move_right", "move_left") * steer_strength
		engine_force = Input.get_axis("move_back", "move_forward") * engine_acceleration
		
