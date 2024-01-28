# controls the countdown
extends Label

var time = 3600 # seconds
var dsec = 0
var seconds =0 
var minutes = 0
var timestarted = false
var flash : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _on_countdown_startinggunfired():
	timestarted = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not timestarted:
		return
	time -= delta
	seconds = fmod(time,60)
	minutes = fmod(time,3600)/60
	var timestring = "%02d : %02d"%[minutes,seconds]

	text = timestring

	if time <= 30:
		add_theme_color_override("font_color", Color("CRIMSON"))
	
	pass

