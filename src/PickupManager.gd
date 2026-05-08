extends Node3D

@export var AnimPlayer:AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pickup_area_body_entered(body: Node3D) -> void:
	if body is Playermanager:
		AnimPlayer.play("Collect")
	pass # Replace with function body.
