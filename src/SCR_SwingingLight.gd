@tool
extends Node3D


@export var Freq:float
@export var Amp:float

@export var SwingPoint:Node3D

@export var LampHead:Node3D

var t:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	t = wrap(t,-PI*2,PI*2)
	
	SwingPoint.rotation_degrees.z = sin(t * Amp) * Freq
	LampHead.rotation.z = -SwingPoint.rotation.z
	pass
