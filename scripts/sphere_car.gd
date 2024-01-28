# From https://kidscancode.org/godot_recipes/4.x/3d/3d_sphere_car/
extends Node3D
class_name SphereCar

@export var ball : RigidBody3D
@export var sphere_offset : Vector3 = Vector3.DOWN*(.35)
@export var acceleration : float = 35.0
@export var steering : float = 19.0
@export var turn_speed : float= 4.0
@export var turn_stop_limit : float = 0.75
@export var body_tilt : float = 170
@export var angular_damp_on_ground : float = 5.0
@export var angular_damp_in_air : float = 0.0

@export var started = false

## attach to the clown stack within. It will be reparented to be a sibling
@export var clown_stack : ClownStack
@export var follow_cam : FollowCam

var speed_input = 0
var turn_input = 0
var enable_ray = false

@export var car_mesh : Node3D
@export var body_mesh : Node3D
@export var ground_ray  : RayCast3D
@export var right_wheel : Node3D
@export var left_wheel : Node3D


var clown_stack_reparented : bool = false
func _on_countdown_startinggunfired():
	started = true
	pass
	
func _ready():
	ground_ray.add_exception(ball)
	
func _physics_process(delta):	
	if ground_ray.is_colliding():
		# Accelerate based on car's forward direction
		ball.apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
		ball.angular_damp = angular_damp_on_ground
	else:
		ball.angular_damp = angular_damp_in_air

	# Keep the car mesh aligned with the sphere
	car_mesh.position = ball.position + sphere_offset
		

func _reparent_clown_stack_if_needed():
	if (!clown_stack_reparented):
		# remove the clown stack and make it a sibling so it doesn't spin along too
		# can't do it in the _ready() because there is no parent yet
		clown_stack.reparent(get_parent(), true)
		print("Clown stack's parent is now: ", clown_stack.get_parent())
		clown_stack_reparented = true

func _process(delta):
	_reparent_clown_stack_if_needed()
	
	if not started:
		return
	if not ground_ray.is_colliding():
		return
		
	speed_input = Input.get_axis("brake","accelerate") * acceleration
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	right_wheel.rotation.y = turn_input+deg_to_rad(90)
	left_wheel.rotation.y = turn_input+deg_to_rad(90)
	
	#
	# rotate car mesh
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_basis : Basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
	
	if ground_ray.is_colliding():
		var n = ground_ray.get_collision_normal()
		var xform = align_with_y(car_mesh.global_transform, n.normalized())
		car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)
	#
	#if linear_velocity.length() > turn_stop_limit:
		#var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y.normalized(), turn_input)
		#car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		#car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		#var t = -turn_input * linear_velocity.length() / body_tilt
		#body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
		#if ground_ray.is_colliding():
			#var n = ground_ray.get_collision_normal()
			#var xform = align_with_y(car_mesh.global_transform, n)
			#car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)
	
	#car_mesh.global_position = global_position + sphere_offset

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
#	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
