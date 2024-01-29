extends RigidBody3D
class_name Clown

# x: getting clown hit by car (layer 2)
# x: after clown hit, passing through car and flung up into the air for the cursor, time slows down. Make clown not collide with car or other clowns for the moment
# x: clown rotates around the cursor until left click
# x: clown is fired towards the car when left click happens - set the collision interactions so that it interacts with clowns and real car
# x: when fired clown hits car or other clown, then it sticks onto them with a joint. If it hits ground, it dies
# TODO: clown dying

enum ClownState {PEDESTRIAN, FLYING, FIRED, CLINGING, DEAD}

## whether the clown has been hit by the car yet
@export var state : ClownState = ClownState.PEDESTRIAN
@export var trigger_area : Area3D
@export var clinging_onto : Node3D = null

@export var head_gear : Array[Node3D] = [] 
@export var neck_accessories : Array[Node3D] = [] 
@export var main_collision_trigger : CollisionShape3D

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
const MAX_SPIN_TIME : float = 3.0

var cam : Camera3D
var circle_time : float = 0.0
var anchor : Node3D
var spin_time_left : float = 3.0
var initial_position : Vector3

static var clinging_clowns : Array[Clown] = []

static func clear_clinging_clowns():
	clinging_clowns.clear()

static func count_clinging_clowns() -> int:
	var count : int = 0
	for clown in clinging_clowns:
		if (clown != null):
			count += 1
			
	return count
	
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = global_position
	_randomize_accessories()
	_update_layers()

func _exit_tree():
	_remove_from_clinging_clowns()
	
func _randomize_accessories():
	#head_gear.pick_random().visible = true
	#neck_accessories.pick_random().visible = true
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		ClownState.FLYING:
			_process_flying(delta)
		ClownState.CLINGING:
			_cling()
			if (clinging_onto != null):
				clinging_onto.rotate_y(deg_to_rad(randf_range(-10.0, 10.0)) * delta)
				clinging_onto.rotate_x(deg_to_rad(randf_range(-10.0, 10.0)) * delta)
				clinging_onto.rotate_z(deg_to_rad(randf_range(-10.0, 10.0)) * delta)

	
func _cling():
	if (state == ClownState.CLINGING):
		if (clinging_onto != null):
			global_position = clinging_onto.global_position
			global_rotation = clinging_onto.global_rotation
		else:
			# otherwise we fall and die
			state = ClownState.DEAD
			_delayed_death()
	
func _process_physics(delta):
	#if (state == ClownState.CLINGING):
		#var v : Vector3 = linear_velocity
		#var diff : Vector3 = clinging_onto.global_position - global_position
		#var target_v :Vector3 = diff / delta
		#var v_diff = target_v - v
		#apply_central_impulse(v_diff * mass)
	_cling()


func _integrate_physics(s):
	if (state == ClownState.CLINGING):
		_cling()
		pass
	
func _process_flying(delta):
	if (state != ClownState.FLYING):
		return
		
	if cam == null:
		cam = get_viewport().get_camera_3d()
	
	if (cam == null):
		return
		
	spin_time_left -= delta
	if (spin_time_left <= 0.0):
		state = ClownState.DEAD
		_update_layers()
		_delayed_death()
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
	
	var v = direction * LAUNCH_SPEED
	if (SphereCar.instance != null):
		v += SphereCar.instance.ball.linear_velocity
		
	apply_central_impulse(v * mass)
	
	
func _update_layers():
	if (trigger_area == null): 
		return
		
	match state:
		ClownState.PEDESTRIAN: # get hit by clown car
			trigger_area.collision_mask = pedestrian_mask
			collision_mask =  pedestrian_mask | 1
		ClownState.FLYING: # we don't care while we're flying and haven't been fired
			trigger_area.collision_mask = flying_mask
			collision_mask =  flying_mask
		ClownState.FIRED:
			trigger_area.collision_mask = fired_mask
			collision_mask =  fired_mask
		ClownState.CLINGING: # clown that was clinging on to stack got hit
			trigger_area.collision_mask = clinging_mask
			collision_mask = clinging_mask
		ClownState.DEAD: # dead clown got hit, not sure what to do
			trigger_area.collision_mask = dead_mask
			collision_mask =  dead_mask
	
func _pedestrian_hit(body):
	if (body is SphereCar or body is ClownStack):		
		print("pedestrian hit by: ", body.name)
		state = ClownState.FLYING
		_update_layers()
		if (SphereCar.instance != null):
			if (!SphereCar.instance.bounce_sound.playing):
				SphereCar.instance.bounce_sound.play()
	
func _fired_clown_hit(body):
	
	if (state != ClownState.FIRED):
		return
		
	print("Collision layer: ", body.collision_layer,  " ", body.name)
	
	var layer = body.collision_layer
	
	if (layer == 4):
		state = ClownState.CLINGING
		print("** Cling onto clownstack: ", body.name)
		_cling_onto(body)
		
		
	if (layer == 8):
		var otherClown = body as Clown
		if (otherClown.state == ClownState.CLINGING):
			print("** Cling onto clinging clown: ", body.name)
			state = ClownState.CLINGING
			_cling_onto(body)
		else:
			print("skipping other clown since it is not clinging")
			
	# ground
	if layer == 1:
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
	clinging_clowns.append(self)
	spin_time_left = MAX_SPIN_TIME
	#main_collision_trigger.scale = Vector3.ONE * 0.1
	
	#var joint : PinJoint3D = PinJoint3D.new()
	#joint.node_a = body.get_path()
	#joint.node_b = get_path()
	#joint.set_param(PinJoint3D.PARAM_BIAS, JOINT_BIAS_STRENGTH)
	#joint.set_param(PinJoint3D.PARAM_DAMPING, JOINT_DAMPING_STRENGTH)
#
	#add_child(joint)
	
	
func _clinging_hit(body):
	# if it is ground then stop clinging
	if (body.collision_layer == 1):
		print("Clown fell off and died!")
		state = ClownState.DEAD
		clinging_onto.queue_free()
		_delayed_death()

func _delayed_death():
	print("death start")
	
	_remove_from_clinging_clowns()
	var effect_prefab = load("res://prefabs/clown_die_effect.tscn")
	var effect : Node3D = effect_prefab.instantiate()
	get_tree().root.add_child(effect)
	effect.global_position = global_position
	effect.global_rotation = global_rotation
	
	
	await get_tree().create_timer(2.0).timeout
	print("death end")
	
	visible = false
	
	effect.queue_free()
		
	await get_tree().create_timer(30.0).timeout
	visible = true
	global_position = initial_position
	linear_velocity = Vector3.ZERO
	state = ClownState.PEDESTRIAN
	#main_collision_trigger.scale = Vector3.ONE
	_update_layers()


func _remove_from_clinging_clowns():
	var index : int = clinging_clowns.find(self)
	if (index != -1):
		clinging_clowns[index] = null
		
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
