extends StaticBody3D
class_name ClownStack
## follows the clowncar, this is the physics receiver for the clown car
@export var acceleration_bonus_per_clown : float = 100.0
@export var sphere_car : SphereCar

@export var clown_count : int = 0

var base_acceleration : float
var old_clown_count : int = -1

func _count_clinging_clowns():
	# loop through all the clowns that are in the clinging state
	# count all the legit ones
	clown_count = Clown.count_clinging_clowns()
	
	if (clown_count != old_clown_count):
		print("clown count: ", clown_count)
		old_clown_count = clown_count

# Called when the node enters the scene tree for the first time.
func _ready():
	Clown.clear_clinging_clowns()
	_count_clinging_clowns()	
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
	_count_clinging_clowns()
	_update_car_stats()
	
	

