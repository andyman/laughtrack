extends Label

var number = 4
var fired = false

signal startinggunfired

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if int(number) > 0:
		text = "%01d"%[number]
	else:
		text = "GO!"
		if not fired:
			startinggunfired.emit()
			fired=true
		if number<=0:
			queue_free()
	number-=delta
	pass
