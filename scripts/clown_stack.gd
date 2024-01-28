extends StaticBody3D
class_name ClownStack
## follows the clowncar, this is the physics receiver for the clown car
@export var acceleration_bonus_per_clown : float = 100.0
@export var sphere_car : SphereCar

@export var clown_count : int = 0

var base_acceleration : float

# Called when the node enters the scene tree for the first time.
func _ready():
	base_acceleration = sphere_car.acceleration
	_update_car_stats()
	_follow()
		
func _follow():
	global_transform = sphere_car.body_mesh.global_transform
	global_rotation = sphere_car.body_mesh.global_rotation
	
func _physics_process(delta):
	_follow()

func _update_car_stats():
	sphere_car.acceleration = base_acceleration +  acceleration_bonus_per_clown * clown_count
	
func _process(delta):
	_follow()
	_update_car_stats()
	
	

