extends Object
class_name Node3DUtils

## rotate a node around the Y axis using the pivot point, with the angles in degrees
static func rotate_around_y(node : Node3D, global_pivot_point : Vector3, angle : float):
	# Step 1: Calculate Local Pivot Point
	var local_pivot : Vector3 = node.to_local(global_pivot_point)
	
	# Step 2: Translate to Pivot Point
	node.transform.origin -= local_pivot
	
	# Step 3: Rotate
	node.global_rotate(Vector3.UP, deg_to_rad(angle))
	
	# Step 4: Translate Back
	node.transform.origin += local_pivot

# returns a quaternion that rotates from_dir to to_dir
static func from_to_rotation_basis(from_dir : Vector3, to_dir : Vector3):
	from_dir = from_dir.normalized()
	to_dir = to_dir.normalized()
	
	var rotation_axis = from_dir.cross(to_dir).normalized()
	var rotation_angle = acos(from_dir.dot(to_dir))
	
	return Basis(rotation_axis, rotation_angle)

static func set_position_and_rotation_for_child(parent : Node3D, child : Node3D, target : Node3D, flatten : bool):
	
	var target_position : Vector3 = target.global_position
	var target_forward : Vector3 = target.global_basis.z
	
	# first rotate so that the child is facing that target forward
	var child_forward : Vector3 = child.global_basis.z
	
	if flatten:
		target_forward.y = 0
		child_forward.y = 0
		
	target_forward = target_forward.normalized()
	child_forward = child_forward.normalized()

	parent.basis *= from_to_rotation_basis(child_forward, target_forward)
	
	# now find the offset between the child and its target position
	# and apply that to the parent
	var offset : Vector3 = target_position - child.global_position
	parent.global_position += offset

static func smallest_signed_angle_difference(a: float, b: float) -> float:
	var diff : float = fmod(abs(a - b), 360.0)
	if diff > 180.0:
		diff = -sign(a - b) * (360.0 - diff)
	else:
		diff = a - b
	return diff
		#
	## Ensure both angles are within the range [0, 360)
	#var angle1 : float = fmod(angle1_degrees, 360.0)
	#var angle2 : float = fmod(angle2_degrees, 360.0)
	#
	## Calculate the absolute difference between the angles
	#var angle_difference : float = angle2 - angle1
	#
	## Adjust the signed difference to be in the range [-180, 180)
	#angle_difference = fmod((angle_difference + 180.0) , 360.0) - 180.0
	#
	#return angle_difference
	
static func calc_angle_between(from_basis: Basis, to_basis: Basis):
	var q1 : Quaternion = from_basis.get_rotation_quaternion()
	
	var q2 : Quaternion = to_basis.get_rotation_quaternion()
	
	# Quaternion that transforms q1 into q2
	var qt = q2 * q1.inverse()
	
	# Angle from quaternion
	var angle = 2 * acos(qt.w)

	# There are two distinct quaternions for any orientation.
	# Ensure we use the representation with the smallest angle.
	if angle > PI:
		qt = -qt
		angle = TAU - angle
	
	# Prevent divide by zero
	if angle < 0.0001:
		return Vector3.ZERO
	
	return angle
	
