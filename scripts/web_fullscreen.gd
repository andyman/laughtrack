extends Node

class_name WebFullscreen

func _input(ev):
	if ev.is_action_pressed('toggle_fullscreen'):
		if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
