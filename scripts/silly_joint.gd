extends Node3D
class_name SillyJoint

## rotation range in degrees along each of the euler axes
@export var rotation_range : Vector3 = Vector3(45.0, 5.0, 45.0)
@export var physics_counterpart : Node3D
@export var clown_root : RigidBody3D

var initial_basis : Basis
var time : float = 0
var next_time : float = 0
var next_basis : Basis
var start_basis : Basis
var start_time : float = 0
func _ready():
	initial_basis = basis
	#physics_counterpart.reparent(clown_root, true)
	
func _process(delta):
	time += delta
	if (time > next_time):
		var rot : Vector3 = Vector3(
			deg_to_rad(randf_range(-rotation_range.y, rotation_range.y)),
			deg_to_rad(randf_range(-rotation_range.x, rotation_range.x)),
			deg_to_rad(randf_range(-rotation_range.z, rotation_range.z))
		)
		
		next_basis = initial_basis * Basis.from_euler(rot)
		next_time = time + randf_range(0.5, 2.0)
		start_time = time
		start_basis = basis
	
	# this should be in physics process but oh well
		
	var weight : float = inverse_lerp(start_time, next_time, time)
	weight = clampf(weight, 0.0, 1.0)
	
	basis = start_basis.slerp(next_basis, weight)
	physics_counterpart.global_position = global_position
	physics_counterpart.global_rotation = global_rotation
		
