extends Node3D
class_name GameController

@export var lap : int = 1
@export var total_laps : int = 2
@export var next_milestone : RaceMilestoneTrigger
@export var game_over : bool = false

static var instance : GameController = null

@export var victory_screen : Control

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

func add_lap():
	lap+=1
	if (lap > total_laps):
		do_finish()
		
func do_finish():
	print("Race Finished!")
	# stop the timer
	game_over = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	victory_screen.visible = true
	await get_tree().create_timer(10.0).timeout
	restart_pressed()
	
func restart_pressed():
	get_tree().change_scene_to_file("res://scenes/laugh_track1.tscn")
