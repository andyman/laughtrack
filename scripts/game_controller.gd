extends Node3D
class_name GameController

@export var lap : int = 1
@export var total_laps : int = 2

static var instance : GameController = null

func _init():
	instance = self

func _exit_tree():
	if (instance == self):
		instance = null
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
