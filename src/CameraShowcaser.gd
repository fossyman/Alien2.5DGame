extends Area3D

@export var CameraHolder:CameraController
@export var CameraPosition:Node3D

@export var CameraHoldTime:float = 1.0
var StartingPosition:Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is Playermanager:
		CameraHolder.FollowTarget = false
		body.velocity = Vector3.ZERO
		body.CanMove = false
		StartingPosition = CameraHolder.global_position
		var t = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.tween_property(CameraHolder,"global_position",CameraPosition.global_position,3.0)
		await t.finished
		await get_tree().create_timer(CameraHoldTime).timeout
		
		var w = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		w.tween_property(CameraHolder,"global_position",StartingPosition,1.0)
		await w.finished
		body.CanMove = true
		CameraHolder.FollowTarget = true
		queue_free()
	pass # Replace with function body.
