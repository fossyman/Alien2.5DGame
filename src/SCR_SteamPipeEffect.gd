extends GPUParticles3D

@export var BuildupTime:Timer
@export var BlowoutTime:Timer

@export var BuildupSFX:AudioStreamPlayer3D
@export var BlowoutSFX:AudioStreamPlayer3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func BuildupTimeout():
	BlowoutTime.start()
	BlowoutSFX.play()
	emitting = true
	pass
	
func BlowoutTimeout():
	BuildupTime.start()
	BuildupSFX.play()
	emitting = false
	pass
