# From https://kidscancode.org/godot_recipes/4.x/3d/3d_sphere_car/
extends RigidBody3D
class_name SphereCar

@export var sphere_offset : Vector3 = Vector3.DOWN*(.35)
@export var acceleration : float = 35.0
@export var steering : float = 19.0
@export var turn_speed : float= 4.0
@export var turn_stop_limit : float = 0.75
@export var body_tilt : float = 170
@export var angular_damp_on_ground : float = 5.0
@export var angular_damp_in_air : float = 0.0

var speed_input = 0
var turn_input = 0
var enable_ray = false

@onready var car_mesh = $clowncar
@export var body_mesh : Node3D
@onready var ground_ray = $clowncar/RayCast3D
@onready var right_wheel = $clowncar/clowncar3/Wheel_FR
@onready var left_wheel = $clowncar/clowncar3/Wheel_FL

#func _ready():
#	ground_ray.add_exception(self)
	
func _physics_process(delta):
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
		angular_damp = angular_damp_on_ground
	else:
		angular_damp = angular_damp_in_air
	
func _process(delta):

	if not ground_ray.is_colliding():
		return
	speed_input = Input.get_axis("brake","accelerate") * acceleration
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	right_wheel.rotation.y = turn_input+deg_to_rad(90)
	left_wheel.rotation.y = turn_input+deg_to_rad(90)

	
	if linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		var t = -turn_input * linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)
	
	car_mesh.position = position + sphere_offset

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
#	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
