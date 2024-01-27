extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
	_copy_background_to_fog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_copy_background_to_fog()
	

func _copy_background_to_fog():
	environment.fog_light_color = environment.background_color
	
