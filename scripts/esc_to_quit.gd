extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if OS.get_name() != "Web":
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().quit()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
