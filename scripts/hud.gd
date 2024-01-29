extends CanvasLayer
class_name HUDController

var time = 3600 # seconds
var dsec = 0
var seconds =0 
var minutes = 0
var timestarted = false
var flash : int = 0


@export var speed_label : Label
@export var clown_label : Label
@export var lap_label : Label
@export var percent_faster_label : Label
@export var final_time_label : Label
@export var timer_label : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (SphereCar.instance != null):
		speed_label.text = "%d" % SphereCar.instance.ball.linear_velocity.length()
		clown_label.text = "%d" % SphereCar.instance.clown_stack.clown_count
		if (SphereCar.instance.clown_stack.clown_count > 0):
			percent_faster_label.text = str(10*SphereCar.instance.clown_stack.clown_count) + "% faster"
		else:
			percent_faster_label.text = ""
	else:
		speed_label.text = "-"
		clown_label.text = "-"
		percent_faster_label.text = ""
	
	if (GameController.instance != null):
		lap_label.text = str(GameController.instance.lap) + "/" + str(GameController.instance.total_laps)
	else:
		lap_label.text = "-/-"
	final_time_label.text = timer_label.text


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
