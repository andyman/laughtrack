extends Node3D

class_name FollowCam

@export var target : Node3D
@export var look_target : Node3D

@export var follow_smoothing_lerp : Vector3 = Vector3(100.0, 5.0, 100.0)
## range of the pitch angle in degrees
@export var pitch_range_min : float = -30.0
@export var pitch_range_max : float = 30.0


## yaw in degrees
@export var yaw : float = 0

## yaw rotation speed in degrees
@export var yaw_speed: float = -0.25

## pitch in degrees
@export var pitch : float = 30
@export var pitch_speed : float = -0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_refresh_camera(-1.0)

func _input(event):
	if (event is InputEventMouseMotion):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			var motion : Vector2 = event.relative as Vector2
			yaw += motion.x * yaw_speed
			pitch += motion.y * pitch_speed
	elif (event is InputEventMouseButton):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_refresh_camera(delta)

func _refresh_camera(delta : float):
	if (target == null):
		return
	
	# move base to the target's position	
	var pos : Vector3 = global_position
	var target_pos : Vector3 = target.global_position
	
	if (delta == -1.0):
		pos = target_pos
	else:
		pos.x = lerp(pos.x, target_pos.x, delta * follow_smoothing_lerp.x)
		pos.y = lerp(pos.y, target_pos.y, delta * follow_smoothing_lerp.y)
		pos.z = lerp(pos.z, target_pos.z, delta * follow_smoothing_lerp.z)
	
	global_position = pos
	
	# apply the rotation
	if (pitch < pitch_range_min):
		pitch = pitch_range_min
		
	elif (pitch > pitch_range_max):
		pitch = pitch_range_max
		
	var new_rotation : Vector3 = Vector3(pitch, yaw, 0.0)
	global_rotation_degrees = new_rotation	
