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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (SphereCar.instance != null):
		speed_label.text = "%d" % SphereCar.instance.ball.linear_velocity.length()
		clown_label.text = "%d" % SphereCar.instance.clown_stack.clown_count
	else:
		speed_label.text = "-"
		clown_label.text = "-"
	
	if (GameController.instance != null):
		lap_label.text = str(GameController.instance.lap) + "/" + str(GameController.instance.total_laps)
	else:
		lap_label.text = "-/-"
