extends Node3D
class_name CameraController

@export var Target:Node3D

var Camera:Camera3D

func _ready() -> void:
	Camera = get_child(0)

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position,Target.global_position,15*delta)
