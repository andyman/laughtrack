extends Node
class_name FollowTarget
@export var target : Node3D
@export var follower : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	follower.global_transform = target.global_transform
	
func _physics_process(delta):
	follower.global_transform = target.global_transform
