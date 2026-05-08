extends Area3D

@export var CameraManager:CameraController

@export var finaleAnimationMesh:Node3D
@export var finaleAnimationPlayer:AnimationPlayer
@export var finaleCamera:Camera3D
@export var finaleCameraAnimationPlayer:AnimationPlayer
@export var Player:Playermanager
func _on_body_entered(body: Node3D) -> void:
	if body is Playermanager:
		body.process_mode = Node.PROCESS_MODE_DISABLED
		CameraManager.Target = finaleAnimationMesh
		finaleCamera.current = true
		finaleAnimationPlayer.play("FINALE_FALL")
		finaleCameraAnimationPlayer.play("FINALE")
	pass # Replace with function body.
