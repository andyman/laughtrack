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
@export_flags_3d_physics var pedestrian_mask
@export_flags_3d_physics var flying_mask
@export_flags_3d_physics var fired_mask
@export_flags_3d_physics var clinging_mask
@export_flags_3d_physics var dead_mask

const DIST_FROM_CAM : float= -5.0
const SPIN_RATE : float = 2.0
const SPIN_LERP_RATE : float = 20.0
const SPIN_RADIUS : float = 0.5
const LAUNCH_SPEED : float = 100.0

var cam : Camera3D
var circle_time : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_layers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		ClownState.FLYING:
			_process_flying(delta)
	

func _process_flying(delta):
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
	print("pedestrian hit")
	state = ClownState.FLYING
	_update_layers()
	
func _fired_clown_hit(body):
	# ground
	if ((body.collision_layer & 1) != 0):
		print("ground hit")
		state = ClownState.DEAD
		_delayed_death()
		
	elif ((body.collision_layer & 4) != 0):
		print("car hit")
		state = ClownState.CLINGING
		_cling_onto(body)
		
	elif ((body.collision_layer & 8) != 0):
		print("clown hit")
		state = ClownState.CLINGING
		_cling_onto(body)
	
	_update_layers()
	
func _cling_onto(body):
	#TODO
	pass
	
func _clinging_hit(body):
	# TODO
	pass
	
func _delayed_death():
	#TODO
	pass
	
func _on_body_entered(body):
	print("Body entered " + body.name)
	

func _on_area3d_body_entered(body):
	print("Body entered " + body.name)
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
