extends RigidBody3D
class_name Clown

# TODO: getting clown hit by car (layer 2)
# TODO: after clown hit, passing through car and flung up into the air for the cursor, time slows down. Make clown not collide with car or other clowns for the moment
# TODO: clown rotates around the cursor until left click
# TODO: clown is fired towards the car when left click happens - set the collision interactions so that it interacts with clowns and real car
# TODO: when fired clown hits car or other clown, then it sticks onto them with a joint. If it hits ground, it dies
# TODO: clown loosening
# TODO: clown ragdolling

enum ClownState {PEDESTRIAN, FLYING, FIRED, CLINGING, DEAD}

## whether the clown has been hit by the car yet
@export var state : ClownState = ClownState.PEDESTRIAN
@export var trigger_area : Area3D
@export var clinging_onto : Node3D = null

@export_flags_3d_physics var pedestrian_mask
@export_flags_3d_physics var flying_mask
@export_flags_3d_physics var fired_mask
@export_flags_3d_physics var clinging_mask
@export_flags_3d_physics var dead_mask

const DIST_FROM_CAM : float= -5.0
const SPIN_RATE : float = 2.0
const SPIN_LERP_RATE : float = 20.0
const SPIN_RADIUS : float = 1
const LAUNCH_SPEED : float = 50.0
const JOINT_BIAS_STRENGTH : float = 1000
const JOINT_DAMPING_STRENGTH : float = 100
const FAKE_JOINT_MAX_IMPULSE : float = 100

var cam : Camera3D
var circle_time : float = 0.0
var anchor : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_layers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		ClownState.FLYING:
			_process_flying(delta)
		ClownState.CLINGING:
			_cling()
	
func _cling():
	if (state == ClownState.CLINGING && clinging_onto != null):
		global_position = clinging_onto.global_position
		global_rotation = clinging_onto.global_rotation
	
func _process_physics(delta):
	if (state == ClownState.CLINGING):
		_cling()


func _integrate_physics(s):
	if (state == ClownState.CLINGING):
		_cling()
	
func _process_flying(delta):
	if (state != ClownState.FLYING):
		return
		
	if cam == null:
		cam = get_viewport().get_camera_3d()
	
	if (cam == null):
		return
		
	# make clown circle around the camera
	circle_time += delta
	var rads = circle_time * TAU * SPIN_RATE
	var target_pos = cam.global_position + cam.global_basis.z * DIST_FROM_CAM + cam.global_basis.x * SPIN_RADIUS * cos(rads) + cam.global_basis.y * SPIN_RADIUS * sin(rads)
	global_position = global_position.lerp(target_pos, delta * SPIN_LERP_RATE)
	
	# make clown face in the camera's direction
	look_at(global_position + cam.global_basis.z, Vector3.UP, true)
	
	# fire the dude forward if it was pressed
	if (Input.is_action_just_pressed("fire")):
		_fire_clown(-cam.global_basis.z)

func _fire_clown(direction : Vector3):
	state = ClownState.FIRED
	_update_layers()
	apply_central_impulse(direction * LAUNCH_SPEED * mass)
	
	
func _update_layers():
	match state:
		ClownState.PEDESTRIAN: # get hit by clown car
			trigger_area.collision_mask = pedestrian_mask
		ClownState.FLYING: # we don't care while we're flying and haven't been fired
			trigger_area.collision_mask = flying_mask
		ClownState.FIRED:
			trigger_area.collision_mask = fired_mask
		ClownState.CLINGING: # clown that was clinging on to stack got hit
			trigger_area.collision_mask = clinging_mask
		ClownState.DEAD: # dead clown got hit, not sure what to do
			trigger_area.collision_mask = dead_mask
	
func _pedestrian_hit(body):
	if (body is SphereCar or body is ClownStack):		
		print("pedestrian hit by: ", body.name)
		state = ClownState.FLYING
		_update_layers()
	
func _fired_clown_hit(body):
	
	if (state != ClownState.FIRED):
		return
		
	print("Collision layer: ", body.collision_layer,  " ", body.name)
	
	var layer = body.collision_layer
	
	if (layer == 4):
		state = ClownState.CLINGING
		print("** Cling onto clownstack: ", body.name)
		_cling_onto(body)
		
		
	elif (layer == 8):
		var otherClown = body as Clown
		if (otherClown.state == ClownState.CLINGING):
			print("** Cling onto clinging clown: ", body.name)
			state = ClownState.CLINGING
			_cling_onto(body)
		else:
			print("skipping other clown since it is not clinging")
			
	# ground
	elif layer == 1:
		print("* ground hit: ", body.name)
		state = ClownState.DEAD
		_delayed_death()

	
	_update_layers()
	

func _cling_onto(body : PhysicsBody3D):
	var anchor : Node3D = Node3D.new()
	body.add_child(anchor)
	
	anchor.global_position = global_position.lerp(body.global_position, 0.25)
	
	anchor.global_rotation = global_rotation

	clinging_onto = anchor
	
	#var joint : PinJoint3D = PinJoint3D.new()
	#joint.node_a = body.get_path()
	#joint.node_b = get_path()
	#joint.set_param(PinJoint3D.PARAM_BIAS, JOINT_BIAS_STRENGTH)
	#joint.set_param(PinJoint3D.PARAM_DAMPING, JOINT_DAMPING_STRENGTH)
#
	#add_child(joint)
	
	
func _clinging_hit(body):

	# TODO
	pass
	
func _delayed_death():
	#TODO
	pass

func _on_area3d_body_entered(body):
	match state:
		ClownState.PEDESTRIAN: # get hit by clown car
			_pedestrian_hit(body)
		ClownState.FLYING: # we don't care while we're flying and haven't been fired
			pass
		ClownState.FIRED:
			_fired_clown_hit(body)
		ClownState.CLINGING: # clown that was clinging on to stack got hit
			_clinging_hit(body)
		ClownState.DEAD: # dead clown got hit, not sure what to do
			pass
