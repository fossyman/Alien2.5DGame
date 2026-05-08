extends Area3D

@export var StepPlayer:AudioStreamPlayer3D
@export var SFX:Array[AudioStream]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(FloorHit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func FloorHit(_body:Node3D):
	StepPlayer.stream = SFX.pick_random()
	StepPlayer.pitch_scale = randf_range(0.9,1.1)
	StepPlayer.play()
